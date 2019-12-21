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

  attr_reader :width, :flat, :portals, :edge_costs,
    :portal_links, :origin, :destination, :name_of

  def initialize maze
    @width = maze.index /\n/
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

      any_updates = false
      neighbors = @edge_costs[node].keys
      neighbors.each do |child|
        alternate = best_distance[node] + @edge_costs[node][child]
        if alternate < best_distance[child]
          # puts "\tnew distance to #{@name_of[child]}(#{child}) is #{alternate}"
          best_distance[child] = alternate
          best_parent[child] = node
          any_updates = true
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

  # def graph
  #   @edge_costs.reduce({}) do |graph, node|
  #     puts "#{node[0]} can reach #{node[1]}"
  #   end
  # end

  def render
    @flat.scan(/.{#{width}}/).gsub('#',' ').join "\n"
  end
end


if __FILE__ == $0
  maze = DonutMaze.new File.read('input20.txt')
  
  # Part 1
  puts maze.best_path maze.origin, maze.destination
end
