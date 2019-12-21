#!/usr/bin/env ruby

require_relative 'intcode'

def send_springdroid spring_script
  cpu = IntcodeComputer.from_file('input21.txt')
  cpu.queue_input *spring_script
  cpu.run
  puts cpu.outputs[-1]
end

part1 =
"OR A T
AND B T
AND C T
NOT T J
AND D J
WALK
".split(//).map(&:ord)

send_springdroid(part1)
# puts "Was it 19360724?"

part2 =
"OR A T
AND B T
AND C T
NOT T J
AND D J
OR E T
OR H T
AND T J
RUN
".split(//).map(&:ord)

send_springdroid(part2)
# puts "Was it 1140450681?"
