#!/usr/bin/env /Users/Danielle/.rvm/wrappers/ruby-1.9.3-p194@honeytreecgi/ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'
require 'lib/honeytree'
require 'cgi'
require 'pp'

cgi = CGI.new 'html3'
params = cgi.params

ht = Honeytree.new
ht.find_nearby_trees params['address'][0], "1"
ht.find_tree_percentages
ht.huffman_encode_trees
ht.parse_for_d3

cgi.out {
    cgi.html {
        cgi.head { 
        	cgi.title { "Honey!" } + "<link rel='stylesheet' type='text/css' href='honeytree.css' />
        	<script type='text/javascript' src='honeytree.js'></script>
        	<script src='http://d3js.org/d3.v2.js'></script>"
        } +
        cgi.body {
        	"<div id='banner'>
				<a href='http://daniellesucher.com'><img src='banner.png' /></a>
			</div>
			<div id='chart'></div>
			<div id='viz'></div>
			<script type='text/javascript'>drawTree(#{ht.d3});</script>"
		}
    }
}
