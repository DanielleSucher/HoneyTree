#!/usr/bin/env ruby

$:.unshift File.expand_path('.')

require 'mysql2'
require 'csv'


@client = Mysql2::Client.new :host => "localhost", :username => "honey",
		:password => "esther", :database => "honeytree"


@client.query "CREATE TABLE IF NOT EXISTS trees (latlong POINT NOT NULL, species VARCHAR(10), 
			  SPATIAL INDEX(latlong)) ENGINE=MyISAM;"


CSV.foreach("trees-kings.csv", :headers => true) do |row|
	puts "in there"
	puts row
	@client.query "INSERT INTO trees (latlong, species) VALUES 
				  (GeomFromText('POINT(#{row['Shape'].gsub(/,|\(|\)/,"")})'), '#{row['SPECIES']}')"
end