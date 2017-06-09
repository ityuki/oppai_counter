# coding: utf-8

# usage
#  > cd tests
#  > irb
#    > load "irb_oppaiload.rb"
#    > @op.check_and_execute("help")

default_external_encoding = Encoding.default_external

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8
puts "debug Oppai!"

require 'json'

Dir.chdir("../lib/oppai") do
  require "../oppai.rb"
end

class Oppai
  class EventProcessor
    attr_reader :config, :oppai_data, :oppai_cmd
  end
  class Data
    def add_oppai_count(count)
      @oppai_count += count
    end
  end

  class TestOppaiLoad
    class WSemu
      def send(json)
        puts JSON.parse(json)['text']
      end
    end
    class EVENTemu
      attr_accessor :data
      def initialize(msg)
        @data = {
          type: "message",
          user: "DUMMY_USER",
          text: msg,
          channel: "DUMMY_CHANNNEL"
        }.to_json
      end
    end
    class Emu
      def initialize(ev)
        @ws = WSemu.new
        @ev = ev
      end
      def send(msg)
        @ev.process(@ws,EVENTemu.new(msg))
      end
    end
  end
end


Dir.chdir("..") do
  @config = { 'token' => "token",'bot_id' => "botid" }
  @data = Oppai::Data.new(0)
  @ev = Oppai::EventProcessor.new(@data,@config)
  @op = @ev.oppai_cmd
  @test = Oppai::TestOppaiLoad::Emu.new(@ev)
end

puts "@data = Oppai::Data, @op = Oppai::Cmd, @ev = Oppai::EventProcessor"
puts 'test message: @test.send("text")'
puts '  example> @test.send("oppai help")'

if $0 == __FILE__
  puts "デバッグモードで実行しています"
  puts "適当に入力すると、oppai_infoの反応が返ります（元々反応しない文字列を入れると反応しません）"
  puts "終了するには、Ctrl+Cなりを押して脱出してください"
  Encoding.default_external = default_external_encoding
  while(true) do
    @test.send(gets.chomp.encode("utf-8"))
  end
end

