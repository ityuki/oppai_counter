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
op_data = Oppai::Data.new
op_util = Oppai::Utils.new(op_data)

## 苦し紛れのおっぱい数継承
if ARGV[0].nil?
  op_data.cnt = 0
else
  op_data.cnt = ARGV[0].to_i
end


# oppai_info本体
EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :message do |event|
    data = JSON.parse(event.data)

    # botの発言はシカト
    if Oppai::Utils.op_judge(data, config['bot_id'])
      # おっぱいコマンドとbotのreplyと編集・削除を除く直近30件の発言を保存
      if data['text'] !~ /^oppai [a-z]+$/ and not data.has_key?('subtype')
        if op_data.mes_list.size < 30
          op_data.mes_list.push(data['text'])
        else
          op_data.mes_list.shift
          op_data.mes_list.push(data['text'])
        end
      end

      # おっぱい数のカウント
      if data['text'] =~ /お.*?っ.*?ぱ.*?い/
        op_data.cnt += data['text'].scan(/お.*?っ.*?ぱ.*?い/).size
      # おっぱいコマンドの呼び出し
      elsif data['text'] =~ /^oppai [a-z]+$/ and not data['text'].include?("\n")
        oppai, cmd = data['text'].split(' ')
        ws.send({
          type: 'message',
          text: op_util.invoke(cmd),
          channel: data['channel']
        }.to_json)
      end
    end
  end

  ws.on :close do
    ws = nil
    EM.stop
    # TODO おっぱい数を記録せよ
  end
end
