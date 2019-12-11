#!/usr/bin/env ruby
require_relative 'intcode'

def find_inputs_for(program, test)
  0.upto(99) do |noun|
    0.upto(99) do |verb|
      state = program.clone
      state[1] = noun
      state[2] = verb
      computer = IntcodeComputer.new(memory: state, run_immediately: true)
      return noun * 100 + verb if computer.memory[0] == test
    end
  end
end

program = File.read('input02.txt').split(',').map(&:to_i)
puts find_inputs_for(program, 19690720)
# puts 'Was it 8478?'
