#!/usr/bin/env ruby

require_relative 'reactions'

equations = File.readlines("input14.txt")

# Part 1
reactions = Reactions.new equations
puts reactions.minimum_ore_for 1, "FUEL"
# puts "Was it 387001?"

# Part 2
puts reactions.fuel_for_ore 1e12
# puts "Was it 3412429?"
