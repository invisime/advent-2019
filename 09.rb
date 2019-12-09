#!/usr/bin/env ruby

require_relative 'intcode'

basic_op_sys_test = File.read('input09.txt').split(',').map(&:to_i)
execute basic_op_sys_test
