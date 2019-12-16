#!/usr/bin/env ruby

require_relative 'intcode'

WALL = 0
EMPTY = 1
OXYGEN = 2
NORTH = 1
SOUTH = 2
WEST = 3
EAST = 4
COMPASS = [NORTH, EAST, SOUTH, WEST]

class Coordinates
  attr_reader :x, :y

  def initialize x, y
    @x, @y = x, y
  end

  def neighbor direction
    x, y = case direction
    when NORTH
      [@x, @y + 1]
    when WEST
      [@x - 1, @y]
    when SOUTH
      [@x, @y - 1]
    when EAST
      [@x + 1, @y]
    end
    Coordinates.new x, y
  end

  def to_s
    "#@x, #@y"
  end

  def == other
    to_s == other.to_s
  end
end

class Robot

  attr_reader :location

  def initialize
    @location = Coordinates.new 0, 0
    @env = IntcodeComputer.from_file "input15.txt"
    @env.run
  end

  def step direction
    @env.queue_input direction
    @env.run
    type = @env.outputs.shift
    @location = @location.neighbor(direction) unless type == WALL
    type
  end
end

class Node
  attr_reader :body, :address, :parent, :type, :direction_from_home, :children

  def initialize body, address, parent, type, direction_from_home
    @body = body
    @address = address
    @type = type
    @parent = parent
    @direction_from_home = direction_from_home
    @children = {}
    raise "Something went wrong" unless @body.location == @address
  end

  def self.origin body
    origin = Node.new body, Coordinates.new(0, 0), nil, [], nil
  end

  def follow path
    return self if path.empty?
    @children[path[0]].follow path[1..-1]
  end

  def path_to_oxygen seen_addresses=[]
    seen_addresses << @address
    return [] if @type == OXYGEN
    COMPASS.each do |direction|
      raise "Something went wrong" unless @body.location == @address
      next if seen_addresses.include? @address.neighbor(direction)
      child = go_to_child(direction)
      next unless child
      if path = child.path_to_oxygen(seen_addresses)
        return [direction] + path
      end
    end
    @body.step direction_to_home
    return false
  end

  def path_to_farthest_point seen_addresses=[]
    seen_addresses << @address
    longest_path = []
    COMPASS.each do |direction|
      raise "Something went wrong" unless @body.location == @address
      next if seen_addresses.include? @address.neighbor(direction)
      child = go_to_child(direction)
      next unless child
      path = [direction] + child.path_to_farthest_point(seen_addresses)
      longest_path = path if path.length > longest_path.length
    end
    @body.step direction_to_home
    longest_path
  end

  def go_to_child direction
    child_type = @body.step(direction)
    return false if child_type == WALL
    @children[direction] = Node.new @body, @address.neighbor(direction), self, child_type, direction
  end

  def direction_to_home
    COMPASS[(COMPASS.index(@direction_from_home) + 2) % 4]
  end
end

if __FILE__ == $0
  # Part 1
  robot = Robot.new
  origin = Node.origin robot
  path_to_oxygen = origin.path_to_oxygen
  puts path_to_oxygen.length
  # puts "Was it 272?"

  oxygen = origin.follow path_to_oxygen
  longest_path = oxygen.path_to_farthest_point
  puts longest_path.length
  # puts "Was it 272?"
end
