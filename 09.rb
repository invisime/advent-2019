#!/usr/bin/env ruby

require_relative 'intcode'

puts "Part 1 or 2?"
basic_op_sys_test = File.read('input09.txt').split(',').map(&:to_i)
execute basic_op_sys_test

# For 1
# puts 'Was it 2457252183?'

# For 2
# puts 'Was it 70634?'
