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
      @white_methods = %w(count word flag per help)
      @destroy_methods = %w(abort throw raise fail exit sleep
                            inspect new clone initialize)
      @likely = LikelyKeyword.new(@white_methods + @destroy_methods)
    end

    def invoke(sent_command)
      if cmd.white_methods.include?(sent_command)
        cmd.send(sent_command.intern)
      elsif cmd.destroy_methods.include?(sent_command)
        "散々苦渋を舐めさせられた `#{sent_command}` は対策済みっぱい。一昨日きやがれっぱい"
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
    rescue => e
      puts e.messagae
      puts e.backtrace
      "よくわからないエラーが発生してるっぱい。ちょっと待つっぱい"
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
