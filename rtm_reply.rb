require 'dotenv'
require 'slack'
require 'yaml'

class RtmReply
  Dotenv.load

  TARGET_CHANNEL = ENV['TARGET_CHANNEL']
  BOT_ID = ENV['BOT_ID']
  OAUTH_TOKEN = ENV['OAUTH_TOKEN']
  BOT_TOKEN = ENV['BOT_TOKEN']
  USER_NAME = '勝手にランチBot'.freeze

  def run
    client = Slack::Client.new(token: OAUTH_TOKEN)
    rtm = Slack::Client.new(token: BOT_TOKEN).realtime
    rtm.on :message do |m|
      if correct_channel?(m) && pass?(m)
        client.chat_postMessage(channel: TARGET_CHANNEL,
                                text: 'りょーかいしました。',
                                as_user: false,
                                username: USER_NAME)
      end
    end
    rtm.start
  end

  private

  def correct_channel?(message)
    message['channel'] == TARGET_CHANNEL
  end

  def pass?(message)
    %(パス ぱす pass Pass PASS).include?(message['text'])
  end
end

rtm_bot = RtmReply.new
rtm_bot.run
