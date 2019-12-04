ORIGIN = {x: 0, y:0}

def set_of_segments description
  description.split(',').reduce([ORIGIN]) do |segments, vector|
    segments += neighbors(vector, segments[-1])
  end
end

def neighbors vector, start
  1.upto(vector[1..-1].to_i).map do |i|
    neighbor(vector, start, i)
  end
end

def neighbor direction, start, i
  x, y = start[:x], start[:y]
  case direction[0]
    when "R"
      {x: x + i, y: y}
    when "L"
      {x: x - i, y: y}
    when "U"
      {x: x, y: y + i}
    when "D"
      {x: x, y: y - i}
  end
end

def manhattan_distance initial, final
  (final[:x] - initial[:x]).abs + (final[:y] - initial[:y]).abs
end

wires = File.readlines('03input.txt').map {|wire| set_of_segments wire}
intersections = wires[0] & wires[1] - [ORIGIN]

# puts intersections.map {|point| manhattan_distance(ORIGIN, point)}.min
puts intersections.map {|point| wires[0].index(point) + wires[1].index(point)}.min
