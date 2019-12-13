#!/usr/bin/env ruby

require_relative 'intcode'

class ArcadeCabinet

  attr_reader :screen
  attr_reader :score
  attr_reader :paddle
  attr_reader :ball

  def initialize free_play=false
    @game = IntcodeComputer.from_file "input13.txt"
    @game.memory[0] = 2 if free_play
    @game.run
    @score = 0
    flush_print_buffer
  end

  def flush_print_buffer
    @screen ||= []
    until @game.outputs.empty?
      x, y, id = @game.outputs.shift(3)
      if [x,y] == [-1,0]
        @score = id
      else
        @screen[y] ||= []
        @screen[y][x] = id
        @paddle = x if id == 3
        @ball = x if id == 4
      end
    end
  end

  def auto_play display: false, debug: false
    until remaining_blocks == 0
      move = @ball <=> @paddle
      @game.queue_input move
      @game.run
      flush_print_buffer      
      render if display
      if debug
        exit if STDIN.gets.chomp == 'q'
      end
    end
    puts "Game over, Man! Game over!"
  end

  def remaining_blocks
    @screen.flatten.select {|id| id == 2}.length
  end

  def render
    puts "\e[3;0H"
    puts "SCORE #@score"
    board = @screen.map do |row|
      row.map do |tile|
        case tile
        when 0
          ' '
        when 1
          '■'
        when 2
          '#'
        when 3
          '_'
        when 4
          'o'
        end
      end.join
    end.join("\n")
    puts board
    puts "Enter Ctrl+C to stop before the end of the game."
  end
end

if __FILE__ == $0
  step_through = ARGV.include?("slowly")
  display = step_through || ARGV.include?("show-me-your-moves")

  # Part 1
  arcade = ArcadeCabinet.new
  puts arcade.remaining_blocks
  #puts "Was it 296?"

  # Part 2
  arcade = ArcadeCabinet.new true
  puts "CAUTION: This part can take a while."
  arcade.auto_play display: display, debug: step_through
  # puts "Was it 13824?"
end
