class Oppai
  class Utils
    class << self
      # bot以外のユーザの発言かどうか判定
      def oppai_judge(data, bot_id)
        if data['user'] != bot_id and data['type'] == 'message'
          true
        else
          false
        end
      end
    end

    def initialize
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
    end

    # おっぱい宣教師語録+α
    def word
      @words.sample
    end

    # おっぱいフラグ
    def flag
      @flags.sample
    end

    def per(mes_list)
      if mes_list.size == 0
        "おっぱわーが足りません"
      else
        begin
          opper = mes_list.reduce(0) { |sum, m| sum += m.scan(/お.*?っ.*?ぱ.*?い/).size }
          per = 100 * opper / mes_list.size
          "現在のおっぱい濃度は #{per} %です"
        rescue
          p mes_list
          "`oppai per` は使えないっぱいです"
        end
      end
    end
  end
end
