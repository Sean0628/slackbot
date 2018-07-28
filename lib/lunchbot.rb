require 'dotenv'
require 'slack'
require 'date'
require 'time'
require './lib/helper.rb'
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
    groups = decide_groups(client, unavailable_user)
    post_message(client, groups)
  end

  private

  def generate_text(groups)
    tmr = Date.today + 1
    <<~"EOS"
    こんにちは。
    明日 *#{format_date(tmr)} 金曜日* 、
    #{format_groups(groups)}
    一緒にランチに行ってらっしゃい :meat_on_bone: :green_salad: :cake:
    EOS
  end

  def format_groups(groups)
    txt = "\n"
    groups.each.with_index(1) do |g, i|
      txt << "TEAM#{i}: #{g}\n"
    end
    txt
  end

  def post_message(client, groups)
    client.chat_postMessage(channel: TARGET_CHANNEL,
                            text: generate_text(groups),
                            as_user: false,
                            username: USER_NAME)
  end

  def get_channel_history(client)
    a_week_ago = Date.today - 7
    client.channels_history(channel: TARGET_CHANNEL,
                            count: 300,
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
    denials = %w[パス ぱす pass Pass PASS]
    unavailable_user = []
    messages.each do |message|
      unavailable_user << message['user'] if denials.include?(message['text'])
    end
    unavailable_user
  end

  def decide_groups(client, user)
    channel_members =
      client.channels_info(channel: TARGET_CHANNEL)['channel']['members']
            .reject { |id| user.include?(id) }
            .map { |id| "<@#{id}>さん" }
            .shuffle
    group_members = []
    group_members << channel_members.shift(4) while channel_members.count >= 4
    group_members.map do |m|
      m << channel_members.shift if channel_members.count > 0
    end
    group_members.map { |m| m.join(' ') }
  end
end

bot = LunchBot.new
bot.run