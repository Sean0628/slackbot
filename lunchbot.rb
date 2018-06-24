require 'dotenv'
require 'slack'
require 'date'
require './helper.rb'

class LunchBot
  include Helper
  Dotenv.load

  TARGET_CHANNEL = ENV['TARGET_CHANNEL']
  BOT_ID = ENV['BOT_ID']
  BOT_TOKEN = ENV['BOT_TOKEN']

  def initialize
    Slack.configure do |config|
      config.token = BOT_TOKEN
    end
  end

  def run
    client = Slack::Client.new
    channel_members = client.channels_info(channel: TARGET_CHANNEL)['channel']['members']
                              .reject! { |id| id == BOT_ID }
                              .map { |id| "<@#{id}>さん" }
    selected_members = channel_members.sample(2).join(' ')
    client.chat_postMessage(channel: TARGET_CHANNEL, text: generate_text(selected_members), as_user: true)
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
end

bot = LunchBot.new
bot.run
