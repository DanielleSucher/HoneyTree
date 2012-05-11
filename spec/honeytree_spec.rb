$:.unshift File.expand_path('.')
require 'lib/honeytree'

def depth(tree)
    if tree.class == Array
    	tree.map! do |node|
    		depth(node)
    	end
        return 1 + tree.max
    else
        return -1
	end
end

describe "Huffman encode trees" do
	before :each do
		@ht = Honeytree.new
		@ht.find_nearby_trees "40.6223262 -73.955483", "1" # EMJC, of course
		@ht.find_tree_percentages
		@ht.huffman_encode_trees
	end

	it "should be 6 levels deep" do
		depth(@ht.encoded).should == 6
	end

	it "should account for 100% of the trees at its root" do
		@ht.encoded[-1].should == 100.0
	end
end