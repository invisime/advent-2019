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
    first_row.upto(first_row + limit - 1) do |row|
      leftmost = nil
      rightmost = nil
      (start + 1).downto(0) do |column|
        status = survey_point(row,column)
        break if status == SAFE && !leftmost.nil?
        if status == TRACTORED
          leftmost = column
          rightmost ||= column
        end
      end
      ([start, leftmost || 0].max).upto(row) do |column|
        status = survey_point(row,column)
        break if status == SAFE && !rightmost.nil?
        if status == TRACTORED
          rightmost = column 
          leftmost ||= column
        end
      end
      start = leftmost.nil? && rightmost.nil? ? 0 : (leftmost + rightmost) / 2
    end
  end

  def left_edge_only_survey limit=@limit, first_row=0, first_column=nil, size:
    start = first_column || first_row
    first_row.upto(first_row + limit - 1) do |row|
      leftmost = nil
      (start + 1).downto(0) do |column|
        status = survey_point(row, column)
        break if status == SAFE && !leftmost.nil?
        leftmost = column if status == TRACTORED
      end
      if !leftmost.nil? && is_bottom_left_square?(row, leftmost, size)
        return { x: leftmost, y: row - size + 1 } 
      end
      start = leftmost || row / 2
    end
    puts "No square found before row #{first_row + limit - 1}"
  end

  def is_bottom_left_square? bottom, left, size
    corners = [
      [bottom, left],
      [bottom - size + 1, left + size - 1]
    ]
    corner_statuses = corners.map {|row_column| survey_point row_column[0], row_column[1] }
    corner_statuses.all? TRACTORED
  end

  def right_edge_only_survey limit=@limit, first_row=0, first_column=nil, size:
    start = first_column || first_row
    first_row.upto(first_row + limit - 1) do |row|
      rightmost = nil
      start.upto(row) do |column|
        status = survey_point(row, column)
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

  def survey_point row, column
    return @map[row][column] unless @map[row][column] == UNEXPLORED
    probe = IntcodeComputer.new(
      memory: Droid::program,
      inputs: [row, column],
      run_immediately: true)
    status = probe.outputs[0]
    @min_x = [column, @min_x || Float::INFINITY].min
    @min_y = [row, @min_y || Float::INFINITY].min
    @max_x = [column, @max_x || 0].max
    @max_y = [row, @max_y || 0].max
    @map[row][column] = status
  end

  def flat_map
    @min_y.upto(@max_y).reduce("") do |flat, row|
      flat + flat_row(row)
    end
  end

  def flat_row row
    @min_x.upto(@max_x).reduce("") do |flat, column|
      flat + TILES[map[row][column]]
    end
  end

  def render
    flat_map.scan(/.{#{@max_x - @min_x + 1}}/).map.with_index {|t,i| t + "\t" + (i + @min_y).to_s}.join "\n"
  end
end

if __FILE__ == $0
  # Part 1
  droid = Droid.new 50
  puts droid.flat_map.count TILES[TRACTORED]
  puts "Was it 152?"

  
  # Part 2
  droid = Droid.new

  #def edge_only_surveys limit=@limit, first_row=0, first_column=nil, size:

  size = 5
  puts left_coords = droid.left_edge_only_survey(1200, size:100)
  puts right_coords = droid.right_edge_only_survey(1200, size:100)
  
  # droid.survey droid.max_y - droid.min_y + 1, droid.min_y

  binding.pry

  # puts (x * 10000 + y)
  # 411 1073 too low (apparently)
  # 411 1074 too low
  # 412 1074 ?
  # 412 1075 not right
  # 556 1071 not right
end
