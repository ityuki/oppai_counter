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

# 諸設定

## botのtokenとidを読み込む
config = YAML.load_file("#{ENV['HOME']}/.oppai")

## Slack RTM APIの利用
res = HTTP.post("https://slack.com/api/rtm.start", params: {
  token: config['token']
})
rc = JSON.parse(res.body)
url = rc['url']

## 苦し紛れのおっぱい数継承
if ARGV[0].nil?
  cnt = 0
else
  cnt = ARGV[0].to_i
end

## Oppai::Utilsのインスタンス作成
op = Oppai::Utils.new

mes_list = []

# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    data = JSON.parse(event.data)

    # おっぱいコマンドとbotのreplyを除く直近30件の発言を保存
    if data['text'] !~ /^oppai [a-z]+$/ and judge(data, config['bot_id'])
      if mes_list.size < 30
        mes_list.push(data['text'])
      else
        mes_list.shift
        mes_listpush(data['text'])
      end
    end

    if data['text'] =~ /お.*?っ.*?ぱ.*?い/ and judge(data, config['bot_id'])
      cnt += data['text'].scan(/お.*?っ.*?ぱ.*?い/).size
    elsif data['text'] == "oppai count" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: "現在#{cnt}おっぱいです",
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai word" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: op.word,
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai flag" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: op.flag,
        channel: data['channel']
      }.to_json)
    # おっぱい濃度(テスト版)
    elsif data['text'] == "oppai per" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: op.per(mes_list),
        channel: data['channel']
      }.to_json)
    elsif data['text'] == "oppai help" and judge(data, config['bot_id'])
      ws.send({
        type: 'message',
        text: "Usage: oppai <subcommand>\n\
               oppai count\tおっぱい数を報告します.\n\
               oppai word\tおっぱい宣教師のありがたい語録を表示します.\n\
               oppai flag\tおっぱいフラグをたてます.\n\
               oppai per\tチャンネル内のおっぱい濃度を表示します.(test)\n\
               oppai help\tこのヘルプを表示します.",
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
