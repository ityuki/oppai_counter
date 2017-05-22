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

    def initialize
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
      @mes_list = []
    end

    def method_missing(name)
      "`#{name}` なんてコマンドはないっぱい。 `oppai help` を見て出直してくるっぱい"
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
        begin
          opper = @mes_list.reduce(0) { |sum, m| sum += m.scan(/お.*?っ.*?ぱ.*?い/).size }
          per = 100 * opper / @mes_list.size
          "現在のおっぱい濃度は #{per} %です"
        rescue => e
          "`oppai per` は使えないっぱいです"
        end
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
