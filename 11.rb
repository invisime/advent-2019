#!/usr/bin/env ruby

require_relative 'intcode'

BLACK = 0
WHITE = 1
CLOCKWISE = 1
COMPASS = ['north', 'east', 'south', 'west']

$squares = {}

def color_of position
  $squares[position] || BLACK
end

def paint position, color
  $squares[position.clone] = color
end

def rotate robot, direction
  index = COMPASS.index robot[:facing]
  offset = direction == CLOCKWISE ? 1 : -1
  index += offset
  index %= COMPASS.length
  robot[:facing] = COMPASS[index]
end

def move_forward robot
  case robot[:facing]
  when 'north'
    robot[:position][:y] += 1
  when 'south'
    robot[:position][:y] -= 1
  when 'east'
    robot[:position][:x] += 1
  when 'west'
    robot[:position][:x] -= 1
  end
end

def simulate_painting robot_program, start_on_white=false
  robot = {
    position: {
      x: 0,
      y: 0
    },
    facing: 'north'
  }
  computer = IntcodeComputer.new memory: robot_program
  paint robot[:position], WHITE if start_on_white

  until computer.complete?
    computer.queue_input color_of(robot[:position])
    computer.run
    new_color, direction = computer.outputs[-2..-1]
    paint robot[:position], new_color
    rotate robot, direction
    move_forward robot
  end
end

def printable_results
  xs = $squares.keys.map {|p| p[:x]}
  ys = $squares.keys.map {|p| p[:y]}
  offset_x = -xs.min
  offset_y = -ys.min
  width = xs.max + offset_x
  height = ys.max + offset_y

  matrix = (height).downto(0).map do |y|
    0.upto(width).map do |x|
      position = {x: x - offset_x, y: y - offset_y}
      color_of(position) == WHITE ? '■' : ' '
    end
  end

  matrix.map {|row| row.join }.join "\n"
end

program = File.read('input11.txt').split(',').map(&:to_i)

# Part 1
simulate_painting program
puts $squares.length
# puts 'Was it 2428?'

# Part 2
$squares = {}
simulate_painting program, true
puts printable_results
# puts 'Was it RJLFBUCU?'
