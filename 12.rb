#!/usr/bin/env ruby

require_relative 'moons'

# Part 1
moons = Moons.new File.read('input12.txt')
1000.times { moons.step! }
puts moons.total_energy
#puts "Was it 12490?"

# Part 2
puts Moons.periodicity File.read('input12.txt')
