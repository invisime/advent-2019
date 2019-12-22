#!/usr/bin/env ruby

require_relative 'intcode'
require 'pry'
require 'pqueue'


class Step
  attr_reader :i, :g, :parent

  def initialize i, g, parent
    @i, @g, @parent = i, g, parent
  end

  def self.origin i
    Step.new i, 0, nil
  end

  def child i
    Step.new i, g + 1, self
  end

  def path
    return [] if parent.nil?
    parent.path + [i]
  end
end

class DonutMaze

  attr_reader :width, :height, :flat, :portals,
    :edge_costs, :portal_links, :origin, :destination

  def initialize maze
    @width = maze.index /\n/
    @height = maze.length / width
    @flat = maze.split(/\n/).join
    scan_portals
    scout_edge_costs
    # binding.pry
  end

  def best_path from, to
    best_distance = Hash.new { Float::INFINITY }
    best_parent = Hash.new
    best_distance[from] = 0
    unexplored = PQueue.new(portal_locations) {|a,b| best_distance[a] < best_distance[b] }
    until unexplored.empty?
      node = unexplored.pop
      # puts "expanding #{@name_of[node]}(#{node}) at distance #{best_distance[node]}"

      # binding.pry if node == to || best_distance[node] == Float::INFINITY

      return best_distance[to] if node == to

      neighbors = @edge_costs[node].keys
      neighbors.each do |child|
        alternate = best_distance[node] + @edge_costs[node][child]
        if alternate < best_distance[child]
          # puts "\tnew distance to #{@name_of[child]}(#{child}) is #{alternate}"
          best_distance[child] = alternate
          best_parent[child] = node
        end
      end

      unexplored.replace(unexplored)
    end
    raise "Could not reach #{to} from #{from}"
  end

  def best_level_conscious_path from, to
    best_distance = Hash.new { Float::INFINITY }
    best_parent = Hash.new
    start = {i: from, level: 0}
    goal = {i: to, level: 0}
    best_distance[start] = 0
    seen = []
    unexplored = PQueue.new([start]) {|a,b| best_distance[a] < best_distance[b] }
    until unexplored.empty?
      door = unexplored.pop
      seen.push door
      node, level = door[:i], door[:level]

      puts "expanding #{@name_of[node]} (level #{level}) at distance #{best_distance[door]}"
      return best_distance[goal] if door == goal

      neighbors = @edge_costs[node].keys.map do |destination|
        up_or_down = 0
        if @edge_costs[node][destination] == 1
          up_or_down = is_outer?(node) ? -1 : 1
        end
        {i: destination, level: level + up_or_down }
      end
      neighbors.delete_if {|c| seen.include? c}
      neighbors.delete_if {|c| c[:level] < 0}
      neighbors.delete_if {|c| c != goal && ["AA", "ZZ"].include?(name_of(c[:i]))}
      neighbors.each do |child_door|
        child_i, child_level = child_door[:i], child_door[:level]
        # binding.pry if child_i < 0
        alternate = best_distance[door] + @edge_costs[node][child_i]
        if alternate < best_distance[child_door]
          puts "\tnew distance to #{@name_of[child_i]} (level #{child_level}) is #{alternate}"
          best_distance[child_door] = alternate
          best_parent[child_door] = node
          unexplored.push child_door
        end
      end

      unexplored.replace(unexplored)
    end
    raise "Could not reach #{to} from #{from}"

  end

  def scout_edge_costs
    @edge_costs = {}
    portal_locations.each do |current|
      distances = {}
      seen = []
      unexplored = [Step.origin(current)]
      until unexplored.empty?
        step = unexplored.shift
        seen.push step.i
        if current != step.i && @portal_links.include?(step.i)
          distances[step.i] = step.g
        end
        traversable_neighbors(step.i).each do |child_i|
          next if seen.include? child_i
          unexplored.push step.child(child_i)
        end
      end
      distances[@portal_links[current]] = 1
      @edge_costs[current] = distances
    end
  end

  def scan_portals
    portals_by_name = Hash.new { Array.new }
    @portal_links = {}
    @name_of = {}
    flat.each_char.with_index do |type, current|
      next unless type =~ /[A-Z]/
      portal_friends = all_neighbors(current).select do |i| 
        i > 0 && flat[i] =~ /[\.A-Z]/
      end
      next unless portal_friends.length == 2

      entry = portal_friends.delete_at portal_friends.find_index {|i| flat[i] == '.'}
      name = (portal_friends + [current]).sort.map{|i| flat[i]}.join

      if name == "AA" || name == "ZZ"
        @portal_links[entry] = entry
      elsif portals_by_name.include? name
        other_end = portals_by_name[name]
        @portal_links[entry] = other_end
        @portal_links[other_end] = entry
      end
      portals_by_name[name] = entry
      @name_of[entry] = name
    end
    @origin = portals_by_name["AA"]
    @destination = portals_by_name["ZZ"]
  end

  def portal_locations
    @portal_links.keys
  end

  def traversable_neighbors from
    all_neighbors(from).select {|i| flat[i] == '.'}
  end

  def all_neighbors from
    [from + 1, from - 1, from + width, from - width].select do |i|
      0 <= i && i < @flat.length && @flat[i] =~ /[\.A-Z]/
    end
  end
  
  def name_of location
    @name_of[location]
  end

  def render
    @flat.gsub('#',' ').scan(/.{#{width}}/).join "\n"
  end

  def is_outer? position
    x, y = position % width, position / width
    y == 2 || x == 2 || y == height - 3 || x == width - 3
  end
end

if __FILE__ == $0
  maze = DonutMaze.new File.read('input20.txt')
  # maze = DonutMaze.new File.read('example20a.txt')
  
  # Part 1
  # puts maze.best_path maze.origin, maze.destination

  # Part 2
  puts maze.best_level_conscious_path maze.origin, maze.destination
end
