require_relative '../intcode'

RSpec.describe IntcodeComputer do
  it "solves Day 2 Part 2" do
    computer = IntcodeComputer.from_file('input02.txt')
    computer.memory[1] = 84
    computer.memory[2] = 78

    computer.run

    expect(computer.memory[0]).to eq(19690720)
  end

  it "solves Day 5 Part 1" do
    computer = IntcodeComputer.from_file('input05.txt')
    
    computer.queue_input 1
    computer.run

    expect(computer.outputs.last).to eq(2845163)
  end

  it "solves Day 5 Part 2" do
    computer = IntcodeComputer.from_file('input05.txt')
    
    computer.queue_input 5
    computer.run

    expect(computer.outputs.last).to eq(9436229)
  end

  it "solves Day 9 Part 1" do
    computer = IntcodeComputer.from_file('input09.txt')
    
    computer.queue_input 1
    computer.run

    expect(computer.outputs.last).to eq(2457252183)
  end

  it "solves Day 9 Part 2" do
    computer = IntcodeComputer.from_file('input09.txt')
    
    computer.queue_input 2
    computer.run

    expect(computer.outputs.last).to eq(70634)
  end
end