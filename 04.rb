#!/usr/bin/env ruby

def monotonic? digits
  max_so_far = 1
  digits.each do |digit|
    return false if digit < max_so_far
    max_so_far = digit
  end
  true
end

def adjacent_equal_pair_not_group? digits
  state = :initial
  previous = nil
  digits.each do |digit|
    case state
    when :initial
      state = :pair_found if digit == previous
    when :pair_found
      if digit == previous
        state = :group_found
      else
        return true
      end
    else # group_found
      state = :initial if digit != previous
    end
    previous = digit
  end
  state == :pair_found
end

possibilities = 165432.upto(707912).filter do |n|
  digits = n.to_s.split('').map(&:to_i)
  monotonic?(digits) && adjacent_equal_pair_not_group?(digits)
end

puts possibilities.count
