require_relative '../moon'
require_relative 'moon_examples'

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

  it "knows state per dimension" do
    moon = Moon.with_position "<x=1, y=-8, z=0>"
    moon.set_velocity_from "<x=-1, y=1, z=3>"

    x, v_x = moon.state_for_dimension :x
    y, v_y = moon.state_for_dimension :y
    z, v_z = moon.state_for_dimension :z

    expect(x).to eq(1)
    expect(y).to eq(-8)
    expect(z).to eq(0)
    expect(v_x).to eq(-1)
    expect(v_y).to eq(1)
    expect(v_z).to eq(3)
  end
end
