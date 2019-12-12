class Moon

  MAGIC_VECTOR_REGEX = /<x=(?<x>-?[\d]+), y=(?<y>-?[\d]+), z=(?<z>-?[\d]+)>/

  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :v_x
  attr_reader :v_y
  attr_reader :v_z

  def initialize position
    @x = position[:x].to_i
    @y = position[:y].to_i
    @z = position[:z].to_i
    @v_x = 0
    @v_y = 0
    @v_z = 0
  end

  def self.with_position vector_string
    vector = vector_string.match MAGIC_VECTOR_REGEX
    Moon.new vector
  end

  def set_velocity_from vector_string
    vector = vector_string.match MAGIC_VECTOR_REGEX
    @v_x = vector[:x].to_i
    @v_y = vector[:y].to_i
    @v_z = vector[:z].to_i
  end

  def gravitate_toward! other_moon
    @v_x += other_moon.x <=> @x
    @v_y += other_moon.y <=> @y
    @v_z += other_moon.z <=> @z
  end

  def step!
    @x += @v_x
    @y += @v_y
    @z += @v_z
  end

  def potential_energy
    [@x, @y, @z].map(&:abs).sum
  end

  def kinetic_energy
    [@v_x, @v_y, @v_z].map(&:abs).sum
  end

  def energy
    potential_energy * kinetic_energy
  end

  def == other_moon
    other_moon.x == @x &&
    other_moon.y == @y &&
    other_moon.z == @z &&
    other_moon.v_x == @v_x &&
    other_moon.v_y == @v_y &&
    other_moon.v_z == @v_z
  end
end

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
    raise "get gud"
  end
end
