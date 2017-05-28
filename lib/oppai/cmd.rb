class Oppai
  class Cmd
    attr_reader :white_methods, :destroy_methods

    def initialize
      @white_methods = %w(count word flag per help)
      @destroy_methods = %w(abort throw raise fail exit sleep
                            inspect new clone initialize)
    end

    # おっぱい数を返す
    def count
      "現在 #{@cnt}おっぱいです"
    end

    # おっぱい宣教師語録+α
    def word
      @words.sample
    end

    # おっぱいフラグ
    def flag
      @flags.sample
    end

    def per
      if @mes_list.size == 0
        "おっぱわーが足りません"
      else
        opper = @mes_list.reduce(0) { |sum, m| sum += m.scan(/お.*?っ.*?ぱ.*?い/).size }
        per = 100 * opper / @mes_list.size
        "現在のおっぱい濃度は #{per} %です"
      end
    end

    def help
      "Usage: oppai <subcommand>\n\
              oppai count\tおっぱい数を報告します.\n\
              oppai word\tおっぱい宣教師のありがたい語録を表示します.\n\
              oppai flag\tおっぱいフラグをたてます.\n\
              oppai per\tチャンネル内のおっぱい濃度を表示します.(test)\n\
              oppai help\tこのヘルプを表示します."
    end
  end
end
