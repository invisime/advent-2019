require_relative '../moons'
require_relative 'moon_examples'

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

  it "measures periodicity at all" do
    expect(Moons.brute_force_periodicity EXAMPLE_INPUT).to eq(2772)
    expect(Moons.periodicity EXAMPLE_INPUT).to eq(2772)
  end
  
  it "measures periodicity efficiently" do
    expect(Moons.periodicity PERF_EXAMPLE_INPUT).to eq(4686774924)
  end
end
