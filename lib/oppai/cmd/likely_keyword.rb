class Oppai
  class Cmd
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
end
