#!/usr/bin/env ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'
require 'honeytree-lib'
require 'optparse'


ht = Honeytree.new
ht.import_csv ARGV[0]