#!/usr/bin/env ruby

require 'pry'

class FFT

  BASE_PATTERN = [0, 1, 0, -1]

  attr_accessor :signal, :phase, :magnitude

  def initialize signal, phase=0, magnitude=nil
    @signal = signal
    @phase = phase
    @magnitude = magnitude || @signal.to_s.length
    @digits = ("%0#{magnitude}d" % @signal).split('').map(&:to_i)
  end

  def next
    @next ||= FFT.new(calculate, @phase + 1, @magnitude)
  end

  def calculate
    1.upto(magnitude).reduce [] do |new_signal, digit|
      pattern = FFT.pattern_for(digit).cycle.take(magnitude)
      products = magnitude.times.map {|i| pattern[i] * @digits[i] }
      new_signal << (products.sum.abs % 10)
    end.map(&:to_s).join.to_i
  end

  def self.pattern_for n
    BASE_PATTERN.reduce [] do |pattern, i|
      pattern += [i] * n
    end.rotate
  end
  
  def short_signal how_short=8
    @digits[0..(how_short-1)].join.to_i
  end
end

if __FILE__ == $0

  # Part 1
  signal = File.read('input16.txt').strip.to_i
  fft = FFT.new signal
  100.times { fft = fft.next }
  puts fft.short_signal
end
