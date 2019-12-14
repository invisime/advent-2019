require_relative '../reaction'

RSpec.describe Reaction do
  it "should parse its equation string" do
    equation = "15 ORE => 20 A"
    reaction = Reaction.new equation

    expect(reaction.to_s).to eq(equation)
    expect(reaction.result.chemical).to eq("A")
    expect(reaction.result.quantity).to eq(20)
    expect(reaction.reagents.length).to eq(1)
    expect(reaction.reagents[0].chemical).to eq("ORE")
    expect(reaction.reagents[0].quantity).to eq(15)
  end
end
