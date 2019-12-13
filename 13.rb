#!/usr/bin/env ruby

require_relative 'intcode'

# Part 1
game = IntcodeComputer.from_file "input13.txt"
game.run
output = game.outputs.clone
draw_commands = []
draw_commands << output.shift(3) until output.empty?
matrix = draw_commands.reduce([]) do |screen, command|
  x, y, id = command
  screen[x] ||= []
  screen[x][y] = id
  screen
end
puts matrix.flatten.select {|id| id == 2}.length
#puts "Was it 296?"
