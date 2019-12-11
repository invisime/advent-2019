#!/usr/bin/env ruby

require_relative 'intcode'

$program = File.read('input09.txt').split(',').map(&:to_i)

def run input
  computer = IntcodeComputer.new(memory: $program)
  computer.queue_input input
  computer.run
  computer.outputs.last
end

# Part 1
puts run 1
# puts 'Was it 2457252183?'

# Part 2
puts run 2
# puts 'Was it 70634?'
