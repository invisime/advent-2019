#!/usr/bin/env ruby

require_relative 'intcode'

$amplifier_control = File.read('input07.txt').split(',').map(&:to_i)

def simple_simulate phase_setting
  phase_setting.reduce(0) do |signal, amp_setting|
    _, log = execute $amplifier_control, [amp_setting, signal], false
    log.last
  end
end

def feedback_simulate phase_setting
  programs = phase_setting.map do |setting|
    dump, log, pointer = execute $amplifier_control, [setting], false
    { memory: dump, instruction: pointer}
  end

  signal = 0

  programs.cycle do |program|
    break unless program[:instruction]
    dump, log, pointer = execute program[:memory], [signal], false, program[:instruction]
    signal = log.last
    program[:memory] = dump
    program[:instruction] = pointer
  end

  signal
end

# example 1
# $amplifier_control = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
# puts simple_simulate [1,0,4,3,2]
# puts 'Was it 65210?'

# Part 1
# phase_settings = 0.upto(4).to_a.permutation.to_a
# thruster_signals = phase_settings.map {|phase_setting| simple_simulate phase_setting }
# puts thruster_signals.max
# puts "Was it 46248?"

# example 2
# $amplifier_control = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
# puts feedback_simulate [9,8,7,6,5]
# puts 'Was it 139629729?'

# Part 1
phase_settings = 5.upto(9).to_a.permutation.to_a
thruster_signals = phase_settings.map {|phase_setting| feedback_simulate phase_setting }
puts thruster_signals.max
# puts "Was it 46248?"

