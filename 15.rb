#!/usr/bin/env ruby

require_relative 'intcode'
require 'io/console'
require 'pry'

class Robot

  WALL = 0
  EMPTY = 1
  OXYGEN = 2
  NORTH = 'w'
  WEST = 'a'
  SOUTH = 's'
  EAST = 'd'
  COMPASS = [NORTH, EAST, SOUTH, WEST]

  attr_reader :x, :y, :facing, :explored

  def initialize free_play=false
    @brain = IntcodeComputer.from_file "input15.txt"
    @brain.run
    @x, @y, @facing = 0, 0, NORTH
    @explored = {}
  end

  def direction keypress
    valid_direction = ' wsad'.index keypress
    raise "Invalid direction #{keypress}" unless valid_direction
    valid_direction
  end

  def new_location wasd
    case wasd
    when NORTH
      { x: @x, y: @y + 1 }
    when WEST
      { x: @x - 1, y: @y }
    when SOUTH
      { x: @x, y: @y - 1 }
    when EAST
      { x: @x + 1, y: @y }
    end
  end

  def step wasd
    @facing = wasd
    location = new_location(wasd)
    return WALL if @explored[location] == WALL

    @brain.queue_input direction(wasd)
    @brain.run
    
    @explored[location] = type = @brain.outputs.shift
    unless type == WALL
      @x, @y = location[:x], location[:y] 
    end
    type
  end

  TILE = {
    WALL => '#',
    EMPTY => '.',
    OXYGEN => '!'
  }
  TILE.default = ' '
  FACING = {
    NORTH => '^',
    WEST => '<',
    SOUTH => 'v',
    EAST => '>'
  }
  def render
    display = ""
    40.downto(0).each do |iy|
      y = iy - 20
      0.upto(80).each do |ix|
        x = ix - 40
        if y == @y && x == @x
          display += FACING[@facing]
        else
          display += TILE[@explored[{x: x, y: y}]]
        end
      end
      display += "\n"
    end
    puts display
  end
end

if __FILE__ == $0
  # step_through = ARGV.include?("slowly")
  # display = step_through || ARGV.include?("show-me-your-moves")
  instructions = "Enter W, A, S, D, or ESC:"
  # Part 1
  print "\e[3;0H"
  puts instructions
  robot = Robot.new
  loop do
    keypress = STDIN.getch.downcase
    
    if keypress == "\e"
      puts "", "Goodbye!"
      exit
    end

    if keypress == '/'
      binding.pry
    else
      type = robot.step keypress
      robot.render
      print "\e[3;0H"
      puts instructions
    end
  end
end
