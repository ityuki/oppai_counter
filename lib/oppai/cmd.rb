class Oppai
  class Cmd
    attr_reader :white_methods, :destroy_methods, :likely

    def initialize(data)
      @white_methods = {
        'count'   => 'おっぱい数を報告します.',
        'word'    => 'おっぱい宣教師のありがたい語録を表示します.',
        'flag'    => 'おっぱいフラグをたてます.',
        'hello'   => '色んな言語でhello worldを表示します.',
        'per'     => 'チャンネル内のおっぱい濃度を表示します.',
        'random'  => 'どれかのコマンドを実行します.',
        'sleep'   => 'ラリホー！',
        'wakeup'  => 'ザメハ！',
        'version' => 'oppai_infoのversionを表示します.',
        'help'    => 'このヘルプを表示します.'
      }
      @destroy_methods = %w(abort throw raise fail exit
                            inspect new clone initialize)
      @likely = LikelyKeyword.new(@white_methods.keys + @destroy_methods,@white_methods.keys)
      @oppai_data = data
    end

    def check_and_execute(sent_command)
      return nil if !check_sleep(sent_command)

      if white_methods.include?(sent_command)
        self.send(sent_command.intern)
      elsif destroy_methods.include?(sent_command)
        "散々苦渋を舐めさせられた `#{sent_command}` は対策済みっぱい。一昨日きやがれっぱい"
      else
        # 似たようなコマンドを探す
        lcmd = likely.word(sent_command)
        if white_methods.include?(lcmd)
          "もしかして `#{lcmd}` っぱい？" + [
            "",
            "\n詳しくは `oppai help` を見直すか、実行してみるといいぱい",
            "\n……じっこうするぱいとでもおもったか！",
            "\nやれやれ。動かしてやるぱい\n" + self.send(lcmd.intern)
          ].sample
        elsif destroy_methods.include?(lcmd)
          "`#{lcmd}` っぽい文字列を入れるなっぱい！"
        else
          "`#{sent_command}` なんてコマンドはないっぱい。 `oppai help` を見て出直してくるっぱい"
        end
      end
    end

    def check_sleep(sent_command)
      if sent_command == 'wakeup' or
         @oppai_data.sleep_start_time.nil?      or
         (Time.now - @oppai_data.sleep_start_time) > 60
        true
      else
        false
      end
    end

    # おっぱい数を返す
    def count
      "現在 #{@oppai_data.oppai_count}おっぱいです"
    end

    # おっぱい宣教師語録+α
    def word
      @oppai_data.words.sample
    end

    # おっぱいフラグ
    def flag
      @oppai_data.flags.sample
    end

    # helloおっぱい
    def hello
      @oppai_data.hello.sample
    end

    def random
      cmd = @white_methods.keys.sample
      if cmd == "random"
        "あぶないぱい。自分で `oppai random` しそうになったぱい"
      else
        self.send(cmd.intern)
      end
    end

    def per
      if @oppai_data.message_list.size == 0
        "おっぱわーが足りません"
      else
        opper = @oppai_data.message_list.reduce(0) { |sum, m| sum += m.scan(/お.*?っ.*?ぱ.*?い/).size }
        per = 100 * opper / @oppai_data.message_list.size
        "現在のおっぱい濃度は #{per} %です"
      end
    end

    def sleep
      @oppai_data.set_sleep_start_time
      "おやぱい"
    end

    def wakeup
      if @oppai_data.sleep_start_time.nil?
        "起きてるっぱい！"
      else
        @oppai_data.set_sleep_start_time(nil)
        "おはぱい"
      end
    end

    def help
      max_length_command = white_methods.keys.max_by {|cmd| cmd.length }
      help_text = "```\n"
      help_text << "Usage: oppai <subcommand>\n"
      white_methods.each do |sub_command, text|
        just_command = sub_command.ljust(max_length_command.length)
        help_text << "\toppai #{just_command}: #{text}\n"
      end
      help_text << "```\n"
      help_text
    end

    def version
      "oppai_info version #{Oppai::VERSION}"
    end
  end
end
