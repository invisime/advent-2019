#!/usr/bin/env ruby

def execute(memory)
  program_counter = 0
  loop do
    instruction = memory[program_counter]
    break if instruction == 99
    params = memory[(program_counter + 1)..(program_counter + 3)]
    modes = instruction.to_s[0..-3].reverse.split('').map(&:to_i)

    arg0 = (modes[0] || 0) == 0 ? memory[params[0]] : params[0]
    arg1 = (modes[1] || 0) == 0 ? memory[params[1]] : params[1]
    increment = 4

    case instruction % 100
    when 1
      memory[params[2]] =  arg0 + arg1
    when 2
      memory[params[2]] = arg0 * arg1
    when 3
      puts 'Input:'
      memory[params[0]] = gets.to_i
      increment = 2
    when 4
      puts arg0
      increment = 2
    when 5
      increment = 3
      if arg0 != 0 then
        program_counter = arg1
        increment = 0
      end
    when 6
      increment = 3
      if arg0 == 0 then
        program_counter = arg1
        increment = 0
      end
    when 7
      memory[params[2]] = arg0 < arg1 ? 1 : 0
    when 8
      memory[params[2]] = arg0 == arg1 ? 1 : 0
    else
      raise "Unknown bytecode #{instruction} reached at program_counter #{program_counter}"
    end

    program_counter += increment
    raise "Program overflow #{program_counter} is beyond #{memory.length}" if program_counter >= memory.length
  end
  return memory
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


# 02 tests
# initial = File.read('input02.txt').split(',').map(&:to_i)
# puts find_inputs_for(initial, 19690720)

# example = [3,0,4,0,99]
# execute example

diagnostic = File.read('input05.txt').split(',').map(&:to_i)
execute diagnostic
