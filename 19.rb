#!/usr/bin/env ruby

require_relative 'intcode'
require 'pry'

UNEXPLORED = -1
SAFE = 0
TRACTORED = 1
TILES = [".","#",' ']

class Droid

  def self.program
    @@program = File.read('input19.txt').strip.split(',').map(&:to_i)
  end

  attr_reader :map, :min_x, :min_y, :max_x, :max_y

  def initialize limit=nil
    @map = Hash.new {|h, row| h[row] = Hash.new { UNEXPLORED } }
    @leftmosts = {}
    @limit = limit || 1
    survey if limit
  end

  def survey limit=@limit, first_row=0
    start = 0
    first_row.upto(first_row + limit) do |y|
      leftmost = nil
      rightmost = nil
      (start).downto(0) do |x|
        status = survey_point(x, y)
        break if status == SAFE && !leftmost.nil?
        if status == TRACTORED
          leftmost = x
          rightmost ||= x
        end
      end
      (start).upto(limit - 1) do |x|
        status = survey_point(x, y)
        break if status == SAFE && !rightmost.nil?
        if status == TRACTORED
          rightmost = x 
          leftmost ||= x
        end
      end
      start = leftmost.nil? && rightmost.nil? ? 0 : (leftmost + rightmost) / 2
    end
  end

  def left_edge_only_survey limit=@limit, first_row=0, first_column=nil, size:
    left_end = first_column || first_row
    first_row.upto(first_row + limit) do |y|
      leftmost = nil
      (left_end + limit).downto(left_end) do |x|
        status = survey_point(x, y)
        break if status == SAFE && !leftmost.nil?
        leftmost = x if status == TRACTORED
      end
      start = leftmost || (y + 1) * 2
    end
    puts "No square found before row #{first_row + limit - 1}"
  end

  def is_bottom_left_square? bottom, left, size
    corners = [
      [bottom, left],
      [bottom - size + 1, left + size - 1]
    ]
    corner_statuses = corners.map {|xy| survey_point xy[0], xy[1] }
    corner_statuses.all? TRACTORED
  end

  def right_edge_only_survey limit=@limit, first_row=0, first_column=nil, size:
    start = first_column || first_row
    first_row.upto(first_row + limit - 1) do |row|
      rightmost = nil
      start.upto(row) do |column|
        status = survey_point(x, y)
        break if status == SAFE && !rightmost.nil?
        rightmost = column if status == TRACTORED
      end
      if !rightmost.nil? && is_top_right_square?(row, rightmost, size)
        return { x: rightmost - size + 1, y: row }
      end
      start = rightmost || row / 2
    end
    puts "No square found before row #{first_row + limit - 1}"
  end

  def is_top_right_square? top, right, size
    corners = [
      [top, right],
      [top + size - 1, right - size +1]
    ]
    corner_statuses = corners.map {|row_column| survey_point row_column[0], row_column[1] }
    corner_statuses.all? TRACTORED
  end

  def survey_point x, y
    puts "looking: #{x},#{y}"
    return @map[y][x] unless @map[y][x] == UNEXPLORED
    status = IntcodeComputer.new(
      memory: Droid::program,
      inputs: [x, y],
      run_immediately: true).outputs[0]
    @min_x = [x, @min_x || Float::INFINITY].min
    @max_x = [x, @max_x || 0].max
    @min_y = [y, @min_y || Float::INFINITY].min
    @max_y = [y, @max_y || 0].max
    puts "found: #{x},#{y}" if status == TRACTORED
    @map[y][x] = status
  end

  def flat_map
    @min_y.upto(@max_y).reduce("") do |flat, y|
      flat + flat_row(y)
    end
  end

  def flat_row y
    @min_x.upto(@max_x).reduce("") do |flat, x|
      flat + TILES[map[y][x]]
    end
  end

  def render
    flat_map.scan(/.{#{@max_x - @min_x + 1}}/).map.with_index {|t,i| t + "\t" + (i + @min_y).to_s}.join "\n"
  end
end

if __FILE__ == $0
  # Part 1
  # droid = Droid.new 50
  # puts droid.flat_map.count TILES[TRACTORED]
  # puts "Was it 152?"
  
  # Part 2
  droid = Droid.new

  # #def edge_only_surveys limit=@limit, first_row=0, first_column=nil, size:

  # size = 5
  puts left_coords = droid.left_edge_only_survey(30, size:3)
  # puts right_coords = droid.right_edge_only_survey(100, size:3)
  
  # droid.survey droid.max_y - droid.min_y + 1, droid.min_y

  binding.pry

  # puts (x * 10000 + y)
  # 411 1073 too low (apparently)
  # 411 1074 too low
  # 412 1074 ?
  # 412 1075 not right
  # 556 1071 not right
end
