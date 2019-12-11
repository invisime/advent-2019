#!/usr/bin/env ruby

require 'pry'

# Returns the state of memory, an array of output values,
# and the current program counter (unless the program is complete).
def execute(program, inputs=nil, verbose=true, continue_from=0, relative=0)
  use_supplied_inputs = !!inputs
  memory = program.clone
  output_log = []
  program_counter = continue_from
  relative_base = relative
  loop do
    instruction = memory[program_counter]
    break if instruction == 99
    params = memory[(program_counter + 1)..(program_counter + 3)]
    modes = instruction.to_s[0..-3].reverse.split('').map(&:to_i)
    addresses = params.map.with_index {|p, i| modes[i] == 2 ? relative_base + p : p}
    arg0, arg1 = (0..1).map do |i|
      (modes[i] || 0) == 1 ? params[i] : (memory[addresses[i]] || 0)
    end
    increment = 4

    case instruction % 100
    when 1
      memory[addresses[2]] = arg0 + arg1
    when 2
      memory[addresses[2]] = arg0 * arg1
    when 3
      input = nil
      if use_supplied_inputs
        input = inputs.shift
        if input
          puts "Supplied input: #{input}" if verbose
        else
          puts "No supplied input, pausing." if verbose
          return memory, output_log, program_counter, relative_base
        end
      else
        print 'Input: '
        input = gets.to_i 
      end
      memory[addresses[0]] = input
      increment = 2
    when 4
      puts arg0 if verbose
      output_log.push arg0
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
      memory[addresses[2]] = arg0 < arg1 ? 1 : 0
    when 8
      memory[addresses[2]] = arg0 == arg1 ? 1 : 0
    when 9
      relative_base += arg0
      increment = 2
    else
      raise "Unknown bytecode #{instruction} reached at program_counter #{program_counter}"
    end

    program_counter += increment
    raise "Program overflow #{program_counter} is beyond #{memory.length}" if program_counter >= memory.length
  end
  [memory, output_log]
end
