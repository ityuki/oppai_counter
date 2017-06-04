class Oppai
  class Data
    attr_accessor :cnt
    attr_reader :mes_list, :words, :flags

    def initialize(cnt)
      @cnt = cnt
      @mes_list = []
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
    end

    def add_oppai(oppai)
      cnt += oppai
    end

    def add_message(message)
      mes_list.push(message)
    end

    def del_message
      mes_list.shift
    end

  end
end
