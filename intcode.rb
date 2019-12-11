class IntcodeComputer

  ADD = 1
  MULTIPLY = 2
  READ = 3
  WRITE = 4
  JUMP_IF_NOT_ZERO = 5
  JUMP_IF_ZERO = 6
  LESS_THAN = 7
  EQUALS = 8
  SET_RELATIVE_BASE = 9
  HALT = 99
  
  IMMEDIATE = 1
  RELATIVE = 2

  attr_reader :memory
  attr_reader :program_counter
  attr_reader :relative_base
  attr_reader :outputs
  attr_reader :inputs

  def initialize memory:, inputs: [], run_immediately: false
    @memory = memory.clone
    @program_counter = 0
    @relative_base = 0
    @inputs = inputs
    @outputs = []
    run if run_immediately
  end

  def self.from_file path
    program = File.read(path).split(',').map(&:to_i)
    IntcodeComputer.new memory: program
  end

  def run
    @stopped = false
    step until @stopped
  end

  def step
    advance = increment
    case instruction
    when ADD
      @memory[ref(3)] = arg(1) + arg(2)
    when MULTIPLY
      @memory[ref(3)] = arg(1) * arg(2)
    when READ
      input = @inputs.shift
      if input 
        @memory[ref(1)] = input
      else
        @stopped = true
        @program_counter -= advance
      end
    when WRITE
      @outputs << arg(1)
    when JUMP_IF_NOT_ZERO
      @program_counter = arg(2) - advance if arg(1) != 0
    when JUMP_IF_ZERO
      @program_counter = arg(2) - advance if arg(1) == 0
    when LESS_THAN
      @memory[ref(3)] = arg(1) < arg(2) ? 1 : 0
    when EQUALS
      @memory[ref(3)] = arg(1) == arg(2) ? 1 : 0
    when SET_RELATIVE_BASE
      @relative_base += arg(1)
    when 99
      @stopped = true
    else
      raise "Unknown bytecode #{instruction} reached at program_counter #{@program_counter}"
    end
    # puts "Did instruction #{instruction} at #{@program_counter}"
    @program_counter += advance
  end

  def increment
    case instruction
    when ADD, MULTIPLY, LESS_THAN, EQUALS
      4
    when JUMP_IF_NOT_ZERO, JUMP_IF_ZERO
      3
    when READ, WRITE, SET_RELATIVE_BASE
      2
    else
      0
    end
  end

  def opcode
    @memory[@program_counter]
  end

  def instruction
    opcode % 100
  end

  def ref n
    location = @memory[@program_counter + n]
    location += @relative_base if mode(n) == RELATIVE
    location
  end

  def arg n
    mode(n) == IMMEDIATE ? @memory[@program_counter + n] : (@memory[ref(n)] || 0)
  end

  def queue_input *inputs
    @inputs += inputs
  end

  def mode n
    opcode.to_s[0..-3].reverse.split('').map(&:to_i)[n - 1] || 0
  end

  def complete?
    @stopped && instruction == HALT
  end
end