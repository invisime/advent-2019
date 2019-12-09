#!/usr/bin/env ruby

$checksum_dictionary = {}
def find_checksum body
  return $checksum_dictionary[body] unless $checksum_dictionary[body].nil?
  satellites = $satellites_of[body] || []
  $checksum_dictionary[body] = satellites.map do |satellite|
    1 + find_checksum(satellite)
  end.sum
end

def address body
  parent = $parent_of[body]
  return [] if parent.nil?
  address(parent) + [parent]
end

orbit_list = File.readlines('input06.txt').map(&:strip)
$satellites_of = orbit_list.reduce({}) do |dict, orbit|
  body, satellite = orbit.split(')')
  dict[body] ||= []
  dict[body] << satellite
  dict
end

puts $satellites_of.keys.map {|body| find_checksum body}.sum
# puts "Was it 186597?"

$parent_of = orbit_list.reduce({}) do |dict, orbit|
  body, satellite = orbit.split(')')
  dict[satellite] = body
  dict
end

my_position = address("YOU")
santas_position = address("SAN")
common_ancestors = my_position & santas_position
puts ((my_position | santas_position) - common_ancestors).length
# puts "Was it 412?"


