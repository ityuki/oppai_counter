class Oppai
  class Utils
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

    attr_reader :cmd

    def initialize(data)
      @cmd = Oppai::Cmd.new(data)
    end

    def invoke(sent_command)
      cmd.check_and_execute(sent_command)
    rescue => e
      puts e.messagae
      puts e.backtrace
      "よくわからないエラーが発生してるっぱい。ちょっと待つっぱい"
    end
  end
  
end
