# coding: utf-8

# usage
#  > cd tests
#  > irb
#    > load "irb_cmd_data.rb"
#    > @op.check_and_execute("help")

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8
puts "debug Oppai::Data and Oppai::Cmd"

Dir.chdir("../lib/oppai") do
  require "../oppai.rb"
end
Dir.chdir("..") do
  @data = Oppai::Data.new(0)
  @op = Oppai::Cmd.new(@data)
end

puts "@data = Oppai::Data, @op = Oppai::Cmd"


