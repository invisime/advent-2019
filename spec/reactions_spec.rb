require_relative '../reactions'
require_relative 'reactions_examples'

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

  COMPLEX_EXAMPLES.each do |answer, example|
    it "should calculate that necessary ore for example #{answer}" do
      reactions = Reactions.new example

      expect(reactions.minimum_ore_for 1, "FUEL").to eq(answer)
    end
  end

  it "should calculate fuel for a trillion ore" do
    reactions = Reactions.new COMPLEX_EXAMPLES[13312]
    
    expect(reactions.fuel_for_ore 1e12.to_i).to eq(82892753)
  end
end
