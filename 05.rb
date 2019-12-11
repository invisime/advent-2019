#!/usr/bin/env ruby

require_relative 'intcode'

$program = File.read('input05.txt').split(',').map(&:to_i)

def run input
  IntcodeComputer.new(
    memory: $program,
    inputs: [input],
    run_immediately: true
  ).outputs.last
end

# Part 1
puts run 1
# puts 'Was it 2845163?'

# Part 2
puts run 5
# puts 'Was it 9436229?'
