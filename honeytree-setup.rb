#!/usr/bin/env ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'
require 'honeytree-lib'
require 'optparse'


ht = Honeytree.new

if ARGV[0] == "tree-details"
	ht.add_details
else
	ht.add_census ARGV[0]
end