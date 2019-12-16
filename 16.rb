#!/usr/bin/env ruby

require 'pry'

class FFT

  BASE_PATTERN = [0, 1, 0, -1]

  attr_reader :digits

  def signal
    @digits.join.to_i
  end

  def initialize digits
    @digits = digits
  end

  def self.from_i signal
    FFT.new signal.to_s.split('').map(&:to_i)
  end

  def self.from_repeating_s string, repetitions=10000
    FFT.new((string * repetitions).split('').map(&:to_i))
  end

  def next!
    @digits = calculate
    self
  end

  def calculate
    1.upto(@digits.length).map do |digit|
      pattern = FFT.pattern_for(digit, @digits.length)
      products = @digits.length.times.map {|i| pattern[i] * @digits[i] }
      products.sum.abs % 10
    end
  end

  def lazy_find! phase=100, offset=nil, length=8
    offset ||= @digits[0,7].join.to_i
    phase.times { lazy_next! offset }
    short_signal offset, length
  end

  def lazy_next! offset
    cursor = @digits[-1]
    2.upto(@digits.length - offset).each do |from_the_back|
      cursor += @digits[-from_the_back]
      @digits[-from_the_back] = cursor %= 10
    end
    self
  end

  @@pattern_dictionary = {}
  def self.pattern_for n, how_many=nil
    how_many ||= n * BASE_PATTERN.length
    key = [n, how_many]
    @@pattern_dictionary[key] ||= BASE_PATTERN.reduce [] do |pattern, i|
      pattern += [i] * n
    end.rotate.cycle.take(how_many)
  end
  
  def short_signal offset=0, length=8
    @digits[offset, length].join.to_i
  end
end

if __FILE__ == $0
  
  raw_signal = File.read('input16.txt')
  # Part 1
  fft = FFT.from_i raw_signal.strip.to_i
  100.times { fft.next! }
  puts fft.short_signal
  puts "Was it 90744714?"

  # Part 2
  fft = FFT.from_repeating_s raw_signal
  output = fft.lazy_find!
  puts "womp womp" if output == 18993332
  binding.pry
end
