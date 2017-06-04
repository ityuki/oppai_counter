class Oppai
  class EventProcessor
    class << self
      # bot以外のユーザの発言かどうか判定
      def op_judge(data, bot_id)
        if data['user'] != bot_id and data['type'] == 'message'
          true
        else
          false
        end
      end
    end

    attr_reader :oppai_data, :oppai_cmd

    def initialize(data)
      @oppai_data = data
      @oppai_cmd = Oppai::Cmd.new(data)
    end

    def process(event)
      slack_data = JSON.parse(event.data)

      # botの発言はシカト
      if op_judge(slack_data, config['bot_id'])
        # おっぱいコマンドとbotのreplyと編集・削除を除く直近30件の発言を保存
        if slack_data['text'] !~ /^oppai [a-z]+$/ and not slack_data.has_key?('subtype')
          if oppai_data.message_list.size < 30
            oppai_data.add_message(slack_data['text'])
          else
            oppai_data.del_message
            oppai_data.add_message(slack_data['text'])
          end
        end

        # おっぱい数のカウント
        if slack_data['text'] =~ /お.*?っ.*?ぱ.*?い/
          oppai_data.add_oppai_count(slack_data['text'].scan(/お.*?っ.*?ぱ.*?い/).size)
        # おっぱいコマンドの呼び出し
        elsif slack_data['text'] =~ /^oppai [a-z]+$/ and not slack_data['text'].include?("\n")
          oppai, cmd = data['text'].split(' ')
          ws.send({
            type:    'message',
            text:    cmd.check_and_execute(cmd),
            channel: data['channel']
          }.to_json)
        end
      end
    end
  end
end
