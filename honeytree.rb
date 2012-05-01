#!/usr/bin/env ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'
require 'honeytree-lib'
require 'optparse'
require 'pp'

ht = Honeytree.new

pp ht.find_tree_percentages(ht.find_nearby_trees("40.6223262 -73.955483", "1")) # EMJC, of course