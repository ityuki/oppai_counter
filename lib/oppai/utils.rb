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

    attr_accessor :cnt, :mes_list
    attr_reader :cmd

    def initialize
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
      @cmd = Oppai::Cmd.new
      
      @mes_list = []
    end

    def invoke(sent_command)
      if cmd.white_methods.include?(sent_command)
        cmd.send(sent_command.intern)
      elsif cmd.destroy_methods.include?(sent_command)
        "散々苦渋を舐めさせられた `#{sent_command}` は対策済みっぱい。一昨日きやがれっぱい"
      else
        "`#{sent_command}` なんてコマンドはないっぱい。 `oppai help` を見て出直してくるっぱい"
      end
    rescue => e
      puts e.messagae
      puts e.backtrace
      "よくわからないエラーが発生してるっぱい。ちょっと待つっぱい"
    end
  end
end
