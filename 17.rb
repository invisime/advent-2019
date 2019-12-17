#!/usr/bin/env ruby

require_relative 'intcode'
require 'pry'

class Scaffold

  PATH = 35
  PIT = 46
  NEWLINE = 10
  UP = 94
  DOWN = 118
  LEFT = 60
  RIGHT = 62

  TILE = {
    PATH => "#",
    PIT => " ",
    NEWLINE => "\n",
    UP => "^",
    DOWN => "v",
    LEFT => "<",
    RIGHT => ">"
  }
  TILE.default '!'

  attr_accessor :grid

  def initialize intmap
    @intmap = intmap
    @grid = @intmap.map do |chr|
      type = TILE[chr]
      binding.pry if type == '!'
      type
    end.join.split("\n")
    @height = @grid.length
    @width = @grid[0].length
  end

  def self.from_file
    Scaffold.new(IntcodeComputer.from_file('input17.txt', run_immediately: true).outputs)
  end

  def is_path? row, column
    @grid[row][column] == TILE[PATH]
  end

  def paths
    return @paths if @paths
    @paths = []
    @height.times do |row|
      @width.times do |column|
        @paths << {row: row, column: column} if is_path? row, column
      end
    end
    @paths
  end

  def is_intersection? position
    @paths.include?(position) &&
    neighbors(position).all? do |neighbor|
      @paths.include?(neighbor)
    end
  end

  def intersections
    @intersections ||= paths.select do |position|
      is_intersection? position
    end
  end

  def alignment_paramenters
    intersections.map { |position| position[:column] * position[:row] }
  end

  def neighbors position
    x, y = position[:column], position[:row]
    positions = []
    positions << { column: x,     row: y + 1 } unless y + 1 >= @height
    positions << { column: x - 1, row: y     } unless x - 1 <= 0
    positions << { column: x,     row: y - 1 } unless y - 1 <= 0
    positions << { column: x + 1, row: y     } unless x + 1 >= @width
    positions
  end
end


# Part 1

# EXAMPLE =
# "..#..........
# ..#..........
# #######...###
# #.#...#...#.#
# #############
# ..#...#...#..
# ..#####...^..".split(//).map(&:ord)
# scaffold = Scaffold.new EXAMPLE
# puts scaffold.alignment_paramenters.sum
# puts "Was it 76?"

scaffold = Scaffold.from_file
puts scaffold.alignment_paramenters.sum
# puts "Was it 2804?"

# Part 2

def get_cpu interactive_mode=false
  cpu = IntcodeComputer.from_file('input17.txt')
  cpu.memory[0] = 2
  cpu.interactive = interactive_mode
  cpu
end

# get_cpu(true)
# fun and useful

program =
"A,B,A,C,A,B,C,C,A,B
R,8,L,10,R,8
R,12,R,8,L,8,L,12
L,12,L,10,L,8
N
"
cpu = get_cpu
cpu.queue_input *program.split(//).map(&:ord)
cpu.run
puts cpu.outputs[-1]
# puts "Was it 833429?"
