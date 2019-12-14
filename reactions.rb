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

  def minimum_ore_for quantity, chemical, existing_quantities=Hash.new{0}
    # ORE just is.
    return quantity if chemical == "ORE"

    # Use what we have.
    if existing_quantities[chemical] >= quantity
      existing_quantities[chemical] -= quantity
      return 0
    elsif existing_quantities[chemical] > 0
      quantity -= existing_quantities[chemical]
      existing_quantities[chemical] = 0
    end

    # Make some of what we need.
    production_yield = @by_result[chemical].result.quantity
    batches = (quantity / production_yield.to_f).ceil
    used_ore = @by_result[chemical].reagents.reduce(0) do |needed_ore, reagent|
      needed_ore + minimum_ore_for(reagent.quantity * batches, reagent.chemical, existing_quantities)
    end

    # Keep the leftovers.
    leftovers = (batches * production_yield) - quantity
    existing_quantities[chemical] += leftovers

    used_ore
  end
end
