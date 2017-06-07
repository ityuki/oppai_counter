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

## Oppaiのインスタンス作成
oppai = File.open('/tmp/log/oppai_count', 'r').read.chomp.to_i
op_data = Oppai::Data.new(oppai)
event_processor = Oppai::EventProcessor.new(op_data, config)


# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    event_processor.process(ws, event)
  end

  ws.on :close do
    ws = nil
    EM.stop
    # TODO おっぱい数を記録せよ
  end
end
