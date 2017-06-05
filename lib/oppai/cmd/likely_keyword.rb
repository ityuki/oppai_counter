class Oppai
  class Cmd
    # にたよーな文字をかえすっぽいやつ
    class LikelyKeyword
      def initialize(keywords,keywordsTrie)
        @keywords = nil
        if keywords.is_a?(Array)
          @keywords = keywords
        elsif keywords.is_a?(String)
          @keywords = [keywords]
        end
        @keywordsTrie = nil
        if keywordsTrie.is_a?(Array)
          @keywordsTrie = keywordsTrie
        elsif keywordsTrie.is_a?(String)
          @keywordsTrie = [keywordsTrie]
        end
        @trie = genTrie(@keywordsTrie)
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
      def levenshtein_words(keyword)
        change_min = 2
        return [] if keyword.size <= change_min or @keywords.nil?
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
      def genTrie(keywords)
        trie = {:next => {}, :term => [] }
        return trie if keywords.nil?
        keywords.each{|kw|
          tc = trie
          kw.split(//).each{|c|
            tc[:term].push(kw)
            tc[:next][c] = {:next => {}, :term => []} if !tc[:next].has_key?(c)
            tc = tc[:next][c]
          }
          tc[:term].push(kw)
        }
        trie
      end
      def trie_words(keyword)
        return [] if keyword.size < 1
        t = @trie
        keyword.split(//).each{|c|
          return [] if !t[:next].has_key?(c)
          t = t[:next][c]
        }
        return t[:term]
      end
      def word(keyword)
        words = levenshtein_words(keyword)
        return words.sample if words.size > 0
        words = trie_words(keyword)
        return words.sample if words.size > 0
        nil
      end
    end
  end
end
