def fuel_for_mass n
  extra_fuel = n / 3 - 2
  return 0 unless extra_fuel > 0
  extra_fuel + fuel_for_mass(extra_fuel)
end

puts File.readlines('01input.txt').map {|n| fuel_for_mass(n.to_i) }.sum
