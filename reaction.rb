class Reaction
  
  attr_reader :result, :reagents

  def initialize equation
    @equation = equation
    lhs, _, rhs = equation.partition("=>")
    @result = Reactant.new rhs
    @reagents = lhs.split(",").map {|part| Reactant.new part }
  end

  def to_s
    @equation.clone
  end
end

class Reactant
  
  attr_reader :quantity, :chemical

  def initialize partial_equation
    quantity, @chemical = partial_equation.match(/(\d+)\s(\w+)/).captures
    @quantity = quantity.to_i
  end

  def is? chemical
    @chemical == chemical
  end
end
