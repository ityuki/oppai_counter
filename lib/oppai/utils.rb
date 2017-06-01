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
      @white_methods = %w(count word flag per help)
      @destroy_methods = %w(abort throw raise fail exit sleep
                            inspect new clone initialize)
      @likely = LikelyKeyword.new(@white_methods + @destroy_methods)
    end

    def invoke(cmd)
      if @white_methods.include?(cmd)
        self.send(cmd.intern)
      elsif @destroy_methods.include?(cmd)
        "散々苦渋を舐めさせられた `#{cmd}` は対策済みっぱい。一昨日きやがれっぱい"
      else
        # 似たようなコマンドを探す
        lcmd = @likely.word(cmd)
        if @white_methods.include?(lcmd)
          "もしかして `#{lcmd}` っぱい？"
        elsif @destroy_methods.include?(lcmd)
          "`#{lcmd}` っぽい文字列を入れるなっぱい！"
        else
          "`#{cmd}` なんてコマンドはないっぱい。 `oppai help` を見て出直してくるっぱい"
        end
      end
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
  
  # にたよーな文字をかえすっぽいやつ
  class LikelyKeyword
    def initialize(keywords)
      @keywords = nil
      if keywords.is_a?(Array)
        @keywords = keywords
      elsif keywords.is_a?(String)
        @keywords = [keywords]
      end
    end
    def levenshtein(a,b)
      x = a.size
      y = b.size
      return y if x == 0
      return x if y == 0
      d = Array.new(x+1){ Array.new(y+1) }
      d.each_with_index{|r,i|
        d[i][0] = i
      }
      d[0].each_with_index{|r,j|
        d[0][j] = j
      }
      a.split(//).each_with_index{|a1,i|
        b.split(//).each_with_index{|b1,j|
          d[i+1][j+1] = [ d[i][j+1]+1, d[i+1][j]+1, d[i][j] + (a1 != b1 ? 1 : 0) ].min
        }
      }
      d[x][y]
    end
    def words(keyword)
      change_min = 2
      return [] if keyword.size < change_min
      kws = []
      max = change_min
      @keywords.each{|kw|
        c = levenshtein(kw,keyword)
        if c <= max
          kws = [] if c != max
          max = c
          kws.push(kw)
        end
      }
      kws
    end
    def word(keyword)
      words(keyword).sample
    end
  end
end
