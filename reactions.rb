require_relative 'reaction'

class Reactions

  attr_accessor :all, :by_result

  def initialize equations
    @all = equations.map {|equation| Reaction.new equation }
    @by_result = @all.reduce({}) do |dictionary, reaction|
      dictionary[reaction.result.chemical] = reaction
      dictionary
    end
  end

  def fuel_for_ore ore
    ore_per_fuel = minimum_ore_for 1, "FUEL"
    materials = Hash.new{0}
    materials["ORE"] = ore
    fuel = 0

    loop do
      minimum_fuel_produced = (materials["ORE"] / ore_per_fuel).floor
      break if minimum_fuel_produced < 1
      fuel += minimum_fuel_produced
      ore_used = minimum_ore_for minimum_fuel_produced, "FUEL", materials, false
    end

    fuel
  end

  def minimum_ore_for quantity, chemical, existing_quantities=Hash.new{0}, ore_is_plentiful=true
    # ORE usually just is.
    return quantity if chemical == "ORE" && ore_is_plentiful

    # Use what we have.
    if existing_quantities[chemical] >= quantity
      existing_quantities[chemical] -= quantity
      return chemical == "ORE" ? quantity : 0
    elsif existing_quantities[chemical] > 0
      quantity -= existing_quantities[chemical]
      existing_quantities[chemical] = 0
    end

    # Make some of what we need.
    production_yield = @by_result[chemical].result.quantity
    batches = (quantity / production_yield.to_f).ceil
    used_ore = @by_result[chemical].reagents.reduce(0) do |needed_ore, reagent|
      needed_ore + minimum_ore_for(reagent.quantity * batches, reagent.chemical, existing_quantities, ore_is_plentiful)
    end

    # Keep the leftovers.
    leftovers = (batches * production_yield) - quantity
    existing_quantities[chemical] += leftovers

    used_ore
  end
end
