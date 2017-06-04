require 'http'
require 'json'
require 'yaml'
require 'eventmachine'
require 'faye/websocket'
require File.expand_path('../lib/oppai.rb', __FILE__)

# 諸設定

## botのtokenとidを読み込む
config = YAML.load_file("#{ENV['HOME']}/.oppai")

## Slack RTM APIの利用
res = HTTP.post("https://slack.com/api/rtm.start", params: {
  token: config['token']
})
rc = JSON.parse(res.body)
url = rc['url']

## Oppai::Utilsのインスタンス作成

## 苦し紛れのおっぱい数継承
if ARGV[0].nil?
  op_data = Oppai::Data.new(0)
else
  op_data = Oppai::Data.new(ARGV[0].to_i)
end
event_processor = Oppai::EventProcessor.new(op_data)


# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    event_processor.process(event)
  end

  ws.on :close do
    ws = nil
    EM.stop
    # TODO おっぱい数を記録せよ
  end
end
