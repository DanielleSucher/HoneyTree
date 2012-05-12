#!/usr/bin/env /Users/Danielle/.rvm/wrappers/ruby-1.9.3-p194@honeytreecgi/ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'
require 'lib/honeytree'
require 'cgi'
require 'pp'

cgi = CGI.new 'html3'
params = cgi.params

header = "<link rel='stylesheet' type='text/css' href='honeytree.css' />
	        	<script type='text/javascript' src='honeytree.js'></script>
	        	<script src='http://d3js.org/d3.v2.js'></script>"

bannerinfo = "<div id='banner'>
				<a href='http://daniellesucher.com'><img src='img/banner.png' /></a>
			</div>
			<div id='info'>
                <a href='http://www.daniellesucher.com/honeytree'>try another location</a> | <a href='https://github.com/DanielleSucher/HoneyTree'>source code</a> | <a href='mailto:dsucher@gmail.com'>email</a>
            </div>"

ht = Honeytree.new
ht.find_nearby_trees params['coords'][0], params['address'][0], "2"

if ht.trees.empty?
	cgi.out {
	    cgi.html {
	        cgi.head { 
	        	cgi.title { "Honey!" } + "#{header}"
	        } +
	        cgi.body {
				"#{bannerinfo}<br><br><br><div id='viz'>Sorry, no trees were found within 2 miles of the location you entered!</div>"
			}
	    }
	}
else
	ht.find_tree_percentages
	ht.huffman_encode_trees
	ht.parse_for_d3

	cgi.out {
	    cgi.html {
	        cgi.head { 
	        	cgi.title { "Honey!" } + "#{header}"
	        } +
	        cgi.body {
	        	"#{bannerinfo}
				<div id='viz'></div>
				<script type='text/javascript'>drawTree(#{ht.d3});</script>"
			}
	    }
	}
end
