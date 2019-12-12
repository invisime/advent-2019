require_relative '../moons'

EXAMPLE_INPUT =
"<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>"

PERF_EXAMPLE_INPUT =
"<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>"

EXAMPLE_VECTORS = [
  {x:-1, y:0, z:2},
  {x:2, y:-10, z:-7},
  {x:4, y:-8, z:8},
  {x:3, y:5, z:-1}
]


RSpec.describe Moon do
  
  it "tracks its own position and velocity" do
    moon = Moon.with_position "<x=-1, y=0, z=2>"
    moon.set_velocity_from "<x=-3, y=-2, z=1>"

    expect(moon.x).to eq(-1)
    expect(moon.y).to eq(0)
    expect(moon.z).to eq(2)
    expect(moon.v_x).to eq(-3)
    expect(moon.v_y).to eq(-2)
    expect(moon.v_z).to eq(1)
  end

  it "gravitates toward other moons" do
    moon_a = Moon.with_position "<x=-1, y=0, z=4>"
    moon_b = Moon.with_position "<x=1, y=0, z=2>"

    moon_a.gravitate_toward! moon_b
    moon_b.gravitate_toward! moon_a

    expect(moon_a.v_x).to eq(1)
    expect(moon_a.v_y).to eq(0)
    expect(moon_a.v_z).to eq(-1)
    expect(moon_b.v_x).to eq(-1)
    expect(moon_b.v_y).to eq(0)
    expect(moon_b.v_z).to eq(1)
  end

  it "moves per its velocity" do
    moon = Moon.with_position "<x=-1, y=1, z=3>"
    moon.set_velocity_from "<x=10, y=1, z=-2>"

    moon.step!

    expect(moon.x).to eq(9)
    expect(moon.y).to eq(2)
    expect(moon.z).to eq(1)
  end

  it "knows its energies" do
    moon = Moon.with_position "<x=1, y=-8, z=0>"
    moon.set_velocity_from "<x=-1, y=1, z=3>"

    expect(moon.potential_energy).to eq(9)
    expect(moon.kinetic_energy).to eq(5)
    expect(moon.energy).to eq(45)
  end
end

RSpec.describe Moons do

  it "tracks moons' positions" do
    moons = Moons.new EXAMPLE_INPUT

    expect(moons.length).to eq(EXAMPLE_VECTORS.length)
    EXAMPLE_VECTORS.each.with_index do |position, i|
      moon = moons[i]
      expect(moon.x).to eq(position[:x])
      expect(moon.y).to eq(position[:y])
      expect(moon.z).to eq(position[:z])
    end
  end

  it "updates velocities over time" do
    moons = Moons.new EXAMPLE_INPUT

    expected_velocities = [
      {x: 3, y:-1, z:-1},
      {x: 1, y: 3, z: 3},
      {x:-3, y: 1, z:-3},
      {x:-1, y:-3, z: 1}
    ]

    moons.step!

    expected_velocities.each.with_index do |velocity, i|
      moon = moons[i]
      expect(moon.v_x).to eq(velocity[:x])
      expect(moon.v_y).to eq(velocity[:y])
      expect(moon.v_z).to eq(velocity[:z])
    end
  end

  it "updates positions over time" do
    moons = Moons.new EXAMPLE_INPUT

    expected_positions = [
      {x: 2, y:-1, z: 1},
      {x: 3, y:-7, z:-4},
      {x: 1, y:-7, z: 5},
      {x: 2, y: 2, z: 0}
    ]

    moons.step!

    expected_positions.each.with_index do |position, i|
      moon = moons[i]
      expect(moon.x).to eq(position[:x])
      expect(moon.y).to eq(position[:y])
      expect(moon.z).to eq(position[:z])
    end
  end
  
  it "measures periodicity" do
    expect(Moons.brute_force_periodicity EXAMPLE_INPUT).to eq(2772)
  end
  
  it "measures periodicity efficiently" do
    expect(Moons.periodicity PERF_EXAMPLE_INPUT).to eq(4686774924)
  end
end
