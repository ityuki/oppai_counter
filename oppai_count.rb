require 'http'
require 'json'
require 'yaml'
require 'eventmachine'
require 'faye/websocket'
require File.expand_path('../oppai_methods.rb', __FILE__)

# 暫定メソッド
def judge(data, bot_id)
  Oppai::Utils.oppai_judge(data, bot_id)
end

def oppai_method(fun)
  Oppai::Utils.send(fun)
end

# 諸設定
config = YAML.load_file("#{ENV['HOME']}/.oppai")
res = HTTP.post("https://slack.com/api/rtm.start", params: {
  token: config['token']
})

rc = JSON.parse(res.body)
url = rc['url']

# 苦し紛れのおっぱい数継承
if ARGV[0].nil?
  cnt = 0
else
  cnt = ARGV[0].to_i
end

# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    data = JSON.parse(event.data)
    if data['text'] =~ /おっぱい/ and judge(data, config['bot_id'])
      cnt += data['text'].scan(/おっぱい/).size
    elsif data['text'] =~ /お.*っ.*ぱ.*い/ and judge(data, config['bot_id'])
      cnt += 1
    elsif data['text'] == "oppai count" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: "現在#{cnt}おっぱいです",
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai word" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: oppai_method(:word),
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai flag" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: oppai_method(:flag),
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai help" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: "Usage: oppai <subcommand>\n\
               oppai count : おっぱい数を報告します.\n\
               oppai word  : おっぱい宣教師のありがたい語録を表示します.\n\
               oppai flag  : おっぱいフラグをたてます.\n\
               oppai help  : このヘルプを表示します.",
        channel: data['channel']
      }.to_json)
    end
  end

  ws.on :close do
    ws = nil
    EM.stop
    # TODO おっぱい数を記録せよ
  end
end
