require 'dotenv'
require 'slack'
require 'date'
require 'time'
require './helper.rb'
require 'yaml'

class LunchBot
  include Helper
  Dotenv.load

  TARGET_CHANNEL = ENV['TARGET_CHANNEL']
  BOT_ID = ENV['BOT_ID']
  OAUTH_TOKEN = ENV['OAUTH_TOKEN']
  USER_NAME = '勝手にランチBot'.freeze

  def run
    client = Slack::Client.new(token: OAUTH_TOKEN)
    message_within1week =
      extract_messages_within1week(get_channel_history(client))
    unavailable_user = extract_unavailable_user(message_within1week) << BOT_ID
    members = pick_members(client, unavailable_user)
    post_message(client, members)
  end

  private
  def generate_text(members)
    next_tuesday = Date.today + 7
    <<~"EOS"
    こんにちは。
    来週 *#{format_date(next_tuesday)} 火曜日* 、
    #{members}
    一緒にランチに行ってらっしゃい :meat_on_bone: :green_salad: :cake:
    EOS
  end

  def post_message(client, members)
    client.chat_postMessage(channel: TARGET_CHANNEL,
                            text: generate_text(members),
                            as_user: false,
                            username: USER_NAME)
  end

  def get_channel_history(client)
    a_week_ago = Date.today - 7
    client.channels_history(channel: TARGET_CHANNEL,
                            oldest: to_unix_ts(a_week_ago))['messages']
  end

  def extract_messages_within1week(history)
    messages_within1week = []
    history.each do |record|
      messages_within1week << record.select { |k| k == 'user' || k == 'text' }
    end
    messages_within1week
  end

  def extract_unavailable_user(messages)
    denials = %w[パス pass ぱす]
    unavailable_user = []
    messages.each do |message|
      unavailable_user << message['user'] if denials.include?(message['text'])
    end
    unavailable_user
  end

  def pick_members(client, user)
    channel_members =
      client.channels_info(channel: TARGET_CHANNEL)['channel']['members']
            .reject { |id| user.include?(id) }
            .map { |id| "<@#{id}>さん" }
    channel_members.sample(4).join(' ')
  end
end

bot = LunchBot.new
bot.run
