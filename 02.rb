#!/usr/bin/env ruby

def execute(intcode)
  position = 0
  loop do
    code = intcode[position]
	break if code == 99
	
    lhs = intcode[intcode[position+1]]
    rhs = intcode[intcode[position+2]]
    destination = intcode[position+3]
	if code == 1
	  intcode[destination] = lhs + rhs
	elsif code == 2
	  intcode[destination] = lhs * rhs
	else
	  raise "Unknown bytecode #{code} reached at position #{position}"
	end
    
	position += 4
    break if position >= intcode.length
  end
  return intcode
end

def find_inputs_for(initial, test)
  0.upto(99) do |noun|
    0.upto(99) do |verb|
      state = initial.clone
	  state[1] = noun
      state[2] = verb
	  return noun * 100 + verb if execute(state)[0] == test
    end
  end
end

initial = File.read('input02.txt').split(',').map(&:to_i)
puts find_inputs_for(initial, 19690720)
