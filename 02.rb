#!/usr/bin/env ruby
require_relative 'intcode'

def find_inputs_for(initial, test)
  0.upto(99) do |noun|
    0.upto(99) do |verb|
      state = initial.clone
	  state[1] = noun
      state[2] = verb
	  return noun * 100 + verb if execute(state)[0][0] == test
    end
  end
end

initial = File.read('input02.txt').split(',').map(&:to_i)
puts find_inputs_for(initial, 19690720)
# puts 'Was it 8478?'
