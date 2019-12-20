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

  INCREMENTS = {
    HALT => 0,
    ADD => 4,
    MULTIPLY => 4,
    LESS_THAN => 4,
    EQUALS => 4,
    JUMP_IF_NOT_ZERO => 3,
    JUMP_IF_ZERO => 3,
    READ => 2,
    WRITE => 2,
    SET_RELATIVE_BASE => 2
  }

  MODE_POSITIONS = [nil, 100, 1000, 10000]
  IMMEDIATE = 1
  RELATIVE = 2

  attr_reader :memory
  attr_reader :program_counter
  attr_reader :relative_base
  attr_reader :outputs
  attr_reader :inputs

  attr_accessor :interactive, :verbose

  def initialize memory:, inputs: [], run_immediately: false
    @memory = memory.clone
    @program_counter = 0
    @relative_base = 0
    @inputs = inputs
    @outputs = []
    run if run_immediately
  end

  def self.from_file path, run_immediately: false
    program = File.read(path).strip.split(',').map(&:to_i)
    IntcodeComputer.new memory: program, run_immediately: run_immediately
  end

  def run
    @stopped = false
    step until @stopped
  end

  def step
    advance = increment
    binding.pry if advance.nil?
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
        if @interactive
          queue_input *gets.split(//).map(&:ord)
        else
          @stopped = true
        end
        @program_counter -= advance
      end
    when WRITE
      @outputs << arg(1)
      print arg(1).chr if @interactive
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
    when HALT
      @stopped = true
    else
      raise "Unknown bytecode #{instruction} reached at program_counter #{@program_counter}"
    end
    puts "Did instruction #{instruction} at #{@program_counter}" if @verbose
    @program_counter += advance
  end

  def opcode
    @memory[@program_counter]
  end

  def instruction
    opcode % 100
  end

  def increment
    INCREMENTS[instruction]
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

  # going right to left, the parameter modes are 0 (hundreds digit),
  # 1 (thousands digit),
  # and 0 (ten-thousands digit, not present and therefore zero)

  def mode n
    binding.pry if MODE_POSITIONS[n].nil?
    opcode / MODE_POSITIONS[n] % 10
  end

  def complete?
    @stopped && instruction == HALT
  end
end