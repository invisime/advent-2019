require_relative 'moon'

class Moons

  def initialize positions_string
    @moons = positions_string.split(/\n/).map {|s| Moon.with_position s}
  end

  def length
    @moons.length
  end

  def [] index
    @moons[index]
  end

  def total_energy
    @moons.map(&:energy).sum
  end

  def step!
    update_velocities!
    @moons.each &:step!
  end

  def update_velocities!
    @moons.combination(2).each do |pair|
      moonA, moonB = pair
      moonA.gravitate_toward! moonB
      moonB.gravitate_toward! moonA
    end
  end

  def == other_moons
    other_moons.length == length
    @moons.each.with_index do |moon, i|
      other_moon = other_moons[i]
      return false unless moon == other_moon
    end
    true
  end

  def state_for_dimension axis
    @moons.map {|moon| moon.state_for_dimension axis}
  end

  def self.brute_force_periodicity positions_string
    initial_state = Moons.new positions_string
    moons = Moons.new positions_string
    moons.step!
    steps = 1
    until moons == initial_state do
      moons.step!
      steps += 1
    end
    steps
  end

  def self.periodicity positions_string
    moons = Moons.new positions_string
    desired_state = [:x, :y, :z].reduce({}) do |states_per_dimension, axis|
      states_per_dimension[axis] = moons.state_for_dimension axis
      states_per_dimension
    end
    periodicity_per_dimension = {}
    steps = 0
    until periodicity_per_dimension.length == 3
      moons.step!
      steps += 1
      [:x, :y, :z].each do |axis|
        unless periodicity_per_dimension[axis]
          has_cycled = desired_state[axis] == moons.state_for_dimension(axis)
          periodicity_per_dimension[axis] = steps if has_cycled
        end
      end
    end
    [:x, :y, :z].map {|axis| periodicity_per_dimension[axis] }.reduce(1, :lcm)
  end
end
