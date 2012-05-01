require 'mysql2'
require 'csv'
require 'pp'

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

	# def set_polygon(numbersides, point, radius)
	# 	# 1 mile = 1/69 degree latitude
	# 	# 1 mile = 1/ (69 * cos(latitude)) degrees longitude
	# 	x = point[0].to_i
	# 	y = point[1].to_i
	# 	lat_r = radius/69.0
	# 	lon_r = radius / (69.0 * Math.cos(radians(x)))
	# 	vertices = "#{x} #{y + lon_r}"
	# 	theta = (Math::PI * 2) / numbersides
	# 	i = 1
	# 	(numbersides - 1).times do 
	# 		vertices.concat(", #{x + lat_r * Math.sin(i * theta)} #{y + lon_r * Math.cos(i * theta)}")
	# 		i += 1
	# 	end
	# 	vertices.concat(", #{x} #{y} + lon_r}")
	# 	"'Polygon((#{vertices}))'"
	# end

	def find_trees_in_square(p, miles)
		x1 = p[0] + miles / 69.0
		y1 = p[1] + miles / (69.0 / Math.cos(self.radians(p[0])))
		x2 = p[0] - miles / 69.0
		y2 = p[1] - miles / (69.0 / Math.cos(self.radians(p[0])))
		line = "LineString(GeomFromText('POINT(#{x1} #{y1})'), GeomFromText('POINT(#{x2} #{y2})'))"
		@client.query "SELECT species, AsText(latlong) FROM trees WHERE MBRContains(#{line}, latlong);"
	end

	def haversine (point1,point2)
	    earth_radius = 3956
	    lat1 = self.radians(point1[0])
	    lon1 = self.radians(point1[1])
	    lat2 = self.radians(point2[0])
	    lon2 = self.radians(point2[1])
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
		results = self.find_trees_in_square(p, m)
		trees = {}
		results.each do |row|
			pt = row["AsText(latlong)"].gsub(/[^\d\s\.-]/, "").split(" ").map! { |x| x = x.to_f }
			dist = haversine(p,pt)
			puts dist
			if dist <= m
				unless row['species'].size <= 1
					trees[row['species']] ||= 0
					trees[row['species']] += 1
				end
			end
		end
		return trees
	end

	def radians(degrees)
		degrees * Math::PI / 180
	end
end

