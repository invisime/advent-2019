#!/usr/bin/env ruby

def coords_from ascii_map
  ascii_map.map.with_index do |line, y|
    line.split('').map.with_index do |reading, x|
      reading == '#' && { x:x, y:y }
    end.select {|o|o}
  end.flatten
end

def intervening_points some_point, other_point
  return [] if some_point == other_point
  delta_x = some_point[:x] - other_point[:x]
  delta_y = some_point[:y] - other_point[:y]
  divisor = delta_x.gcd(delta_y)
  step_x = delta_x / divisor
  step_y = delta_y / divisor
  1.upto(divisor-1).map do |i|
    {
      x: other_point[:x] + step_x * i,
      y: other_point[:y] + step_y * i
    }
  end
end

$asteroids = coords_from File.readlines('input10.txt')

# Part 1
def clear_line_of_sight? some_point, other_point
  return false if some_point == other_point
  potential_blockers = intervening_points some_point, other_point
  !potential_blockers.any? {|point| $asteroids.include? point}
end

def asteroids_visible_to some_point
  $asteroids.select do |other_point|
    clear_line_of_sight? some_point, other_point
  end
end

facilities = $asteroids.map {|point|
  {
    observees: asteroids_visible_to(point),
    x: point[:x],
    y: point[:y]
  }
}
best_facility = facilities.reduce({observees:[]}) do |best, facility|
  facility[:observees].length > best[:observees].length ? facility : best
end

puts best_facility[:observees].length
# puts "Was it 227?"

# Part 2
# Since we're only interested in the 200th asteroid, and there are 227 visible
# to start with, the laser will complete less than a full turn, and we don't
# have to do anything other than sort the visible asteroids by angle.

def clockwise_distance_from_noon point, origin
  x, y = point[:x] - origin[:x], -(point[:y] - origin[:x])
  if x == 0
    return y >= 0 ? 0 : 1
  end
  radians = Math.atan(x.to_f / y) / Math::PI
  if y < 0
    radians += 1
  elsif x < 0
    radians += 2
  end
  radians
end

vaporization_order = best_facility[:observees].sort do |a,b|
  clockwise_distance_from_noon(a, best_facility) <=>
  clockwise_distance_from_noon(b, best_facility)
end

puts vaporization_order[199][:x] * 100 + vaporization_order[199][:y]
# puts "Was it 604?"
