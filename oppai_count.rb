require 'http'
require 'json'
require 'yaml'
require 'eventmachine'
require 'faye/websocket'

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

EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    data = JSON.parse(event.data)
    if data['text'] =~ /お.*っ.*ぱ.*い/ and data['user'] != config['bot_id'] and data['type'] == 'message'
      cnt += 1
    elsif data['text'] == "oppai count" and data['type'] == 'message' and data['user'] != config['bot_id']
      ws.send({
        type: 'message',
        text: "現在#{cnt}おっぱいです",
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai help" and data['type'] == 'message' and data['user'] != config['bot_id']
      ws.send({
        type: 'message',
        text: "Usage: oppai <subcommand>\n\soppai count : display sum of oppai.\n oppai help : display this message.",
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
