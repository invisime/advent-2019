#!/usr/bin/env ruby

width = 25
height = 6

layer_size = height * width

flattened_layers = File.read('input08.txt').strip.scan(/.{#{layer_size}}/).map {|layer| layer.split(//).map(&:to_i)}

# Part 1
layer_histograms = flattened_layers.map do |layer|
  layer.reduce({}) do |histogram, pixel|
    histogram[pixel] ||= 0
    histogram[pixel] += 1
    histogram
  end
end

least_zeroes_histogram = layer_histograms.min {|a,b| a[0] <=> b[0]}
puts least_zeroes_histogram[1] * least_zeroes_histogram[2]

#Part 2
flattened_render = layer_size.times.map do |i|
  layers_for_pixel = flattened_layers.map {|layer| layer[i]}
  layers_for_pixel.reduce(2) do |visible_color, layer_color|
    case visible_color
    when 0..1
      visible_color
    else
      layer_color
    end
  end
end

BLACK = 'X'
WHITE = ' '

encoded_render = flattened_render.map do |pixel|
  case pixel
  when 0
    BLACK
  when 1
    WHITE
  else
    'X'
  end
end

render = encoded_render.join.scan(/.{#{width}}/).join("\n")

puts render

# looks like ZPZVB but is actually ZPZUB
