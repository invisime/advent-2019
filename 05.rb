#!/usr/bin/env ruby

require_relative 'intcode'

diagnostic = File.read('input05.txt').split(',').map(&:to_i)
execute diagnostic, [1]
puts 'Was it 2845163?'

execute diagnostic, [5]
puts 'Was it 9436229?'
