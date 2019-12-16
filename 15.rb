#!/usr/bin/env ruby

require_relative 'intcode'
require 'io/console'
require 'pry'

WALL = 0
EMPTY = 1
OXYGEN = 2
NORTH = 'w'
WEST = 'a'
SOUTH = 's'
EAST = 'd'
COMPASS = [NORTH, EAST, SOUTH, WEST]

class Robot

  attr_reader :x, :y, :facing, :visited, :could_visit

  def initialize free_play=false
    @brain = IntcodeComputer.from_file "input15.txt"
    @brain.run
    @x, @y, @facing = 0, 0, NORTH
    @visited, @could_visit = [], []
  end

  def direction keypress
    valid_direction = ' wsad'.index keypress
    valid_direction || nil
  end

  def know_about
    @visited | @could_visit
  end

  def neighbor wasd
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

  def neighbors
    COMPASS.map {|direction| neighbor direction}
  end

  def opposite wasd
    COMPASS[(COMPASS.index(wasd) + 2) % 4]
  end

  def step wasd
    @facing = wasd
    location = neighbor(wasd)
    return WALL if @know_about[location] == WALL

    command = direction(wasd)
    return unless command
    @brain.queue_input command
    @brain.run

    @visited[location] = type = @brain.outputs.shift
    unless type == WALL
      @x, @y = location[:x], location[:y]
    end
    type
  end

  def explore
    new_options = peek!
    if new_options.length == 1
      step new_options.first
      return 1 + explore
    end
    return 0
  end

  def peek!
    original_facing = @facing
    choices = COMPASS.reduce([]) do |new_empty_directions, wasd|
      next new_empty_directions if @know_about.include? neighbor(wasd)
      type = step wasd
      unless type == WALL
        step opposite(wasd)
        new_empty_directions << wasd
      end
      new_empty_directions
    end
    @facing = original_facing
    choices
  end

  # def peek
  #   peek!.each {|direction| @visited.delete(neighbor direction)}
  # end

  def interactive_mode
    print `clear`
    feedback = ""
    peek
    @visited 
    loop do
      puts "\e[3;0H"
      MindVisualizer.display self
      puts feedback
      puts "Enter spacebar (to let it explore on its own), W, A, S, D, or ESC."
      keypress = STDIN.getch.downcase
      case keypress
      when "\e"
        puts `clear`, "Goodbye!"
        exit
      when '/'
        binding.pry
      when ' '
        steps = explore
        feedback = "I went #{steps} steps before I found a fork in the road."
      when /[wasd]/
        returning = @visited.include? neighbor(keypress)
        step keypress
        peek unless returning
      end
    end
  end
end

class MindVisualizer
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
  def self.display robot
    display = ""
    40.downto(0).each do |iy|
      y = iy - 20
      0.upto(80).each do |ix|
        x = ix - 40
        if y == robot.y && x == robot.x
          display += FACING[robot.facing]
        else
          display += TILE[robot.visited[{x: x, y: y}]]
        end
      end
      display += "\n"
    end
    puts display
  end
end

if __FILE__ == $0
  # Part 1
  Robot.new.interactive_mode
end
