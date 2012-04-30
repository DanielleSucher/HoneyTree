require 'mysql2'
require 'csv'

class Honeytree

	def initialize
		@client = Mysql2::Client.new :host => "localhost", :username => "honey",
									 :password => "esther", :database => "honeytree"
	end

	def create_table
		@client.query "CREATE TABLE IF NOT EXISTS trees (latlong POINT NOT NULL, species VARCHAR(10), 
			  		   SPATIAL INDEX(latlong)) ENGINE=MyISAM;"
	end

	def import_csv(file)
		CSV.foreach(file, :headers => true) do |row|
			puts "in there"
			puts row
			@client.query "INSERT INTO trees (latlong, species) VALUES 
						  (GeomFromText('POINT(#{row['Shape'].gsub(/,|\(|\)/,"")})'), '#{row['SPECIES']}')"
		end
	end

	def setup(file)
		self.create_table
		self.import_csv file
	end

	def set_polygon(point)
		@client.query "SET @poly = 'Polygon((30000 15000,
				                             31000 15000,
				                             31000 16000,
				                             30000 16000,
				                             30000 15000))';"
		# Those are temporary numbers as a placeholder
		# TODO make this function actually work!
	end

	def find_nearby_trees
		@client.query "SELECT AsText(latlong), species FROM trees WHERE
					   MBRContains(GeomFromText(@poly),latlong);"
	end

end

