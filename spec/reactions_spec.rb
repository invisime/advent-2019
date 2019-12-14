require_relative '../reactions'

EXAMPLES =
"10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL".split("\n")

COMPLEX_EXAMPLE = 
"9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL".split("\n")

RSpec.describe Reactions do
  
  it "should parse its equation strings" do
    reactions = Reactions.new EXAMPLE

    expect(reactions.all.map(&:to_s)).to match_array(EXAMPLE)
    expect(reactions.by_result["FUEL"].to_s).to eq(EXAMPLE[-1])
  end

  it "should calculate necessary ore in simple systems" do
    reactions = Reactions.new EXAMPLE

    expect(reactions.minimum_ore_for 10, "ORE").to eq(10)
    expect(reactions.minimum_ore_for 10, "A").to eq(10)
    expect(reactions.minimum_ore_for 2, "B").to eq(2)
    expect(reactions.minimum_ore_for 1, "C").to eq(11)
    expect(reactions.minimum_ore_for 1, "FUEL").to eq(31)
  end

  it "should calculate necessary ore in complex systems" do
    leftovers = Hash.new{0}
    reactions = Reactions.new COMPLEX_EXAMPLE

    ore = reactions.minimum_ore_for 1, "FUEL", leftovers

    expect(reactions.minimum_ore_for 10, "A").to eq(45)
    expect(reactions.minimum_ore_for 24, "B").to eq(64)
    expect(reactions.minimum_ore_for 40, "C").to eq(56)
    expect(ore).to eq(165)
  end
end
