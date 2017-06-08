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
oppai = 0
oppai = File.open('/tmp/log/oppai_count', 'r') do { |f| oppai = f.read.chomp.to_i }
op_data = Oppai::Data.new(oppai)
event_processor = Oppai::EventProcessor.new(op_data, config)

# TODO Dockerが異常終了した時にシグナルは送られるか？
trap(:INT) {
  File.open('/tmp/log/oppai_count', 'w') { |f| f.puts(op_data.oppai_count) }
  exit
}

# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    event_processor.process(ws, event)
  end

  ws.on :close do
    ws = nil
    File.open('/tmp/log/oppai_count', 'w') { |f| f.puts(op_data.oppai_count) }
    EM.stop
  end
end
