class Oppai
  class EventProcessor
    def initialize(data, config)
      @config = config
      @oppai_data = data
      @oppai_cmd = Oppai::Cmd.new(data)
    end

    def process(ws, event)
      slack_data = JSON.parse(event.data)

      # botの発言はシカト
      if op_judge(slack_data, @config['bot_id'])
        # おっぱいコマンドとbotのreplyと編集・削除を除く直近30件の発言を保存
        if slack_data['text'] !~ /^oppai [a-z]+$/ and not slack_data.has_key?('subtype')
          if @oppai_data.message_list.size < 30
            @oppai_data.add_message(slack_data['text'])
          else
            @oppai_data.del_message
            @oppai_data.add_message(slack_data['text'])
          end
        end

        # おっぱい数のカウント
        if slack_data['text'] =~ /お.*?っ.*?ぱ.*?い/
          @oppai_data.add_oppai_count(slack_data['text'].scan(/お.*?っ.*?ぱ.*?い/).size)
        # おっぱいコマンドの呼び出し
        elsif slack_data['text'] =~ /^oppai [a-z]+$/ and not slack_data['text'].include?("\n")
          oppai, sent_command = slack_data['text'].split(' ')
          msg = invoke(sent_command)
          if ! msg.nil?
            ws.send({
              type:    'message',
              text:    msg,
              channel: slack_data['channel']
            }.to_json)
          end
        end
      end
    end

    private

    def op_judge(data, bot_id)
      if data['user'] != bot_id and data['type'] == 'message'
        true
      else
        false
      end
    end

    def invoke(sent_command)
      @oppai_cmd.check_and_execute(sent_command)
    rescue => e
      puts e.message
      puts e.backtrace
      "よくわからないエラーが発生してるっぱい。ちょっと待つっぱい"
    end

  end
end
