class Oppai
  class Data
    attr_reader :oppai_count, :message_list, :words, :flags, :hello,
                :sleep_start_time

    def initialize(oppai_count)
      @oppai_count = oppai_count
      @message_list = []
      @sleep = false
      @sleep_start_time = nil
      @words = File.open(File.expand_path('./dicts/word.opp')).readlines.map(&:chomp)
      @flags = File.open(File.expand_path('./dicts/flag.opp')).readlines.map(&:chomp)
      @hello = File.open(File.expand_path('./dicts/hello.opp')).readlines.map(&:chomp).map{|s| '`' + s.gsub(/`/,'｀') + '`' }
    end

    def add_oppai_count(count)
      @oppai_count += count
      File.open('/tmp/log/oppai_count', 'w') { |f| f.puts(@oppai_count) }
    end

    def add_message(message)
      @message_list.push(message)
    end

    def del_message
      @message_list.shift
    end

    def set_sleep_start_time(time = Time.now)
      @sleep_start_time = time
    end

  end
end
