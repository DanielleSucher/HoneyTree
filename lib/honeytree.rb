require 'mysql2'
require 'csv'
require 'pp'

class Honeytree
	attr_accessor :client, :trees, :percentages, :encoded

	def initialize
		@client = Mysql2::Client.new :host => "localhost", :username => "honey",
									 :password => "esther", :database => "honeytree"
		@trees = {}
		@percentages = {}
		@encoded = []
	end

	def create_census_table
		@client.query "CREATE TABLE IF NOT EXISTS trees (latlong POINT NOT NULL, species VARCHAR(10), 
			  		   SPATIAL INDEX(latlong)) ENGINE=MyISAM;"
	end

	def create_details_table
		@client.query "CREATE TABLE IF NOT EXISTS details (id INT Not Null Auto_Increment, Primary 
					   key(id), symbol VARCHAR(10), name VARCHAR(120), season VARCHAR(20));"
	end

	def import_tree_census(file)
		CSV.foreach(file, :headers => true) do |row|
			@client.query "INSERT INTO trees (latlong, species) VALUES 
						  (GeomFromText('POINT(#{row['Shape'].gsub(/,|\(|\)/,"")})'), '#{row['SPECIES']}')"
		end
	end

	def import_details
		CSV.foreach("tree-details", :headers => true) do |row|
			@client.query "INSERT INTO details (symbol, name, season) VALUES ('#{row['symbol']}',
						   '#{row['name']}', '#{row['season']}')"
		end
	end

	def add_census(file)
		create_census_table
		import_tree_census file
	end

	def add_details
		create_details_table
		import_details
	end

	def find_trees_in_square(p, miles)
		x1 = p[0] + miles / 69.0
		y1 = p[1] + miles / (69.0 / Math.cos(radians(p[0])))
		x2 = p[0] - miles / 69.0
		y2 = p[1] - miles / (69.0 / Math.cos(radians(p[0])))
		line = "LineString(GeomFromText('POINT(#{x1} #{y1})'), GeomFromText('POINT(#{x2} #{y2})'))"
		@client.query "SELECT details.name, AsText(trees.latlong) FROM trees,details WHERE 
					   MBRContains(#{line}, trees.latlong)
					   AND trees.species=details.symbol;"
	end

	def haversine (point1,point2)
	    earth_radius = 3956
	    lat1 = radians(point1[0])
	    lon1 = radians(point1[1])
	    lat2 = radians(point2[0])
	    lon2 = radians(point2[1])
	    dlat = lat2 - lat1
	    dlon = lon2 - lon1
	    a = (Math.sin(dlat/2.0))**2 + Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2.0))**2
		great_circle_distance = 2 * Math.asin([1, Math.sqrt(a)].min)

	    d = earth_radius * great_circle_distance
	end

	def find_nearby_trees(point, miles)
		p = point.split(" ")
		p.map! { |x| x = x.to_f }
		m = miles.to_f
		results = find_trees_in_square(p, m)
		results.each do |row|
			# puts row
			pt = row["AsText(trees.latlong)"].gsub(/[^\d\s\.-]/, "").split(" ").map! { |x| x = x.to_f }
			dist = haversine(p,pt)
			if dist <= m
				@trees[row['name']] ||= 0
				@trees[row['name']] += 1
			end
		end
	end

	def radians(degrees)
		degrees * Math::PI / 180
	end

	def find_tree_percentages
		total = 0
		@trees.each { |k,v| total += v }
		@trees.each do |k,v|
			p = ((v * 100.0) / total).round(2)
			@percentages[k] = p if p >= 1
		end
		@percentages['other'] = (100 - @percentages.inject(0) { |res,(k,v)| res + v }).round(2)
	end

	def huffman_encode_trees
		@encoded = @percentages.sort_by { |k,v| v }
		until @encoded.length == 1
			a,b = @encoded.shift, @encoded.shift
			branch = [a, b, (a[-1] + b[-1]).round(2)]
			@encoded.push branch
			@encoded.sort! { |a,b| a[-1] <=> b[-1] }
		end
		@encoded = @encoded[0]
	end
end