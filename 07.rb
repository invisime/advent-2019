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

# Part 1
phase_settings = 0.upto(4).to_a.permutation.to_a
thruster_signals = phase_settings.map {|phase_setting| simple_simulate phase_setting }
puts thruster_signals.max
# puts "Was it 46248?"

# Part 2
phase_settings = 5.upto(9).to_a.permutation.to_a
thruster_signals = phase_settings.map {|phase_setting| feedback_simulate phase_setting }
puts thruster_signals.max
# puts "Was it 54163586?"
