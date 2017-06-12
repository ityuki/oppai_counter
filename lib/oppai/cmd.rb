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
      cmd, *arg = sent_command.split(/ +/)
      if white_methods.include?(cmd)
        self.send(cmd.intern,arg)
      elsif destroy_methods.include?(cmd)
        "散々苦渋を舐めさせられた `#{cmd}` は対策済みっぱい。一昨日きやがれっぱい"
      else
        # 似たようなコマンドを探す
        lcmd = likely.word(cmd)
        if white_methods.include?(lcmd)
          "もしかして `#{lcmd}` っぱい？" + [
            -> c,a {""},
            -> c,a {"\n詳しくは `oppai help` を見直すか、実行してみるといいぱい"},
            -> c,a {"\n……じっこうするぱいとでもおもったか！"},
            -> c,a {"\nやれやれ。動かしてやるぱい\n" + self.send(c.intern,a)}
          ].sample.call(lcmd,arg)
        elsif destroy_methods.include?(lcmd)
          "`#{lcmd}` っぽい文字列を入れるなっぱい！"
        else
          "`#{cmd}` なんてコマンドはないっぱい。 `oppai help` を見て出直してくるっぱい"
        end
      end
    end

    # おっぱい数を返す
    def count(arg)
      "現在 #{@oppai_data.oppai_count}おっぱいです"
    end

    # おっぱい宣教師語録+α
    def word(arg)
      @oppai_data.words.sample
    end

    # おっぱいフラグ
    def flag(arg)
      @oppai_data.flags.sample
    end

    # helloおっぱい
    def hello(arg)
      @oppai_data.hello.sample
    end

    def random(arg)
      cmd = @white_methods.keys.sample
      if cmd == "random"
        "あぶないぱい。自分で `oppai random` しそうになったぱい"
      else
        self.send(cmd.intern,arg)
      end
    end

    def per(arg)
      if @oppai_data.message_list.size == 0
        "おっぱわーが足りません"
      else
        opper = @oppai_data.message_list.reduce(0) { |sum, m| sum += m.scan(/お.*?っ.*?ぱ.*?い/).size }
        per = 100 * opper / @oppai_data.message_list.size
        "現在のおっぱい濃度は #{per} %です"
      end
    end

    def sleep(arg)
      @oppai_data.set_sleep_start_time
      "おやぱい"
    end

    def wakeup(arg)
      if @oppai_data.sleep_start_time.nil?
        "起きてるっぱい！"
      else
        @oppai_data.set_sleep_start_time(nil)
        "おはぱい"
      end
    end

    def help(arg)
      if arg.nil? or arg.size < 1
        help_text = "```\n"
        help_text << "Usage: oppai help <subcommand>\n"
        help_text << "\t<subcommand>:" + white_methods.keys.join(",") + "\n"
        help_text << "\t詳しくはoppai help <subcommand>を実行するぱい\n"
        help_text << "```\n"
      else
        cmd = arg[0]
        if white_methods.include?(cmd)
          max_length_command = white_methods.keys.max_by {|cmd| cmd.length }
          just_command = cmd.ljust(max_length_command.length)
          help_text = "```\n"
          help_text << "Usage: oppai #{cmd}\n"
          help_text << "\toppai #{just_command}: #{white_methods[cmd]}\n"
          help_text << "```\n"
        else
          help_text = "`#{cmd}` なんてオプションは無いぱい\n"
          help_text << "`oppai help` を見返してくるぱい\n"
        end
      end
      help_text
    end

    def version(arg)
      "oppai_info version #{Oppai::VERSION}"
    end
  end
end
