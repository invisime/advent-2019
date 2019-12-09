#!/usr/bin/env ruby

require_relative 'intcode'

puts "('1' for Part 1 or '5' for Part 2)"
diagnostic = File.read('input05.txt').split(',').map(&:to_i)
execute diagnostic

# For 1
# puts 'Was it a bunch of 0s then a 2845163?'

# For 5
# puts 'Was it 9436229?'
