class Oppai
  class Data
    attr_accessor :cnt, :mes_list
    attr_reader :words, :flags

    def initialize(count)
      @cnt = count
      @mes_list = []
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
    end
  end
end
