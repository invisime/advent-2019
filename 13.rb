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
    steps = 0
    until remaining_blocks == 0
      steps += 1
      move = @ball <=> @paddle
      @game.queue_input move
      @game.run
      flush_print_buffer
      if display
        render debug
      else
        print "." if (steps % 1000) == 0
      end
      if debug
        command = STDIN.gets.chomp
        exit if command == 'q'
        if command == '!'
          debug = false 
          print `clear`
        end
      end
    end
    puts "",
      "Game over, Man! Game over!",
      "Final score: #@score"
  end

  def remaining_blocks
    @screen.flatten.select {|id| id == 2}.length
  end

  def render show_instructions
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
    if show_instructions
      puts "Press Enter to step forward.",
        "Enter '!' to switch to auto-advance.",
        "Enter 'q' to quit."
    else 
      puts "Press Ctrl+C to stop before the end of the game.\n\n"
    end
  end
end

if __FILE__ == $0
  step_through = ARGV.include?("slowly")
  display = step_through || ARGV.include?("show-me-your-moves")

  print `clear` if display

  # Part 1
  arcade = ArcadeCabinet.new
  puts "#{arcade.remaining_blocks} blocks to break."
  #puts "Was it 296?"

  # Part 2
  arcade = ArcadeCabinet.new true
  arcade.auto_play display: display, debug: step_through
  # puts "Was it 13824?"
end
