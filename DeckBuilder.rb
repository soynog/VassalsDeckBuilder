#!/usr/bin/env ruby

# Heraldy Module includes info about tinctures, charges, etc.
module Heraldry
	# These hashes help translate the Blazon from numbers into descriptions of the Vassal aspects.
	BLAZ = {0 => "Escutcheon", 1 => "Field A", 2 => "Field B", 3 => "Charge A", 4 => "Charge A Tincture", 5 => "Charge B", 6 => "Charge B Tincture"}
	ESCT = {1 => "Iberian", 2 => "Swiss", 3 => "French"}
	TINC = {0 => nil, 1 => "Argent", 2 => "Or", 3 => "Sable", 4 => "Gules", 5 => "Azure"}
	CHRG = {0 => nil, 1 => "Crescent", 2 => "Fleur-de-Lis", 3 => "Cross", 4 => "Rose", 5 => "Lion", 6 => "Eagle"}
	BLAZ_TYPE = [ESCT,TINC,TINC,CHRG,TINC,CHRG,TINC]
end

# Defines a Vassal
class Vassal
	include Heraldry
	
	# Initializes a new vassal
	def initialize(name, blazon)
		@name = name
		@blazon = blazon
		@esc = blazon[0]
		@fldA = blazon[1]
		@fldB = blazon[2]
		@chgA = blazon[3]
		@chgB = blazon[4]
		@chgA_tinc = blazon[5]
		@chgB_tinc = blazon[6]
	end
	
	# Attribute Accessors for all instance variables (e.g. vassal.name, vassal.name=)
	attr_accessor :name, :blazon, :esc, :fldA, :fldB, :chgA, :chgB, :chgA_tinc, :chgB_tinc

	def inspect(style='t')
		if style == 'v'
			print "Name: #{@name}\n" + "Escutcheon: #{ESCT[@esc]}\n" + "Field: #{TINC[@fldA]} and #{TINC[@fldB]}\n" + "Charges: #{CHRG[@chgA]} #{TINC[@chgA_tinc]} and #{CHRG[@chgB]} #{TINC[@chgB_tinc]}\n"
		elsif style == 't'
			print "#{@name}"
			@blazon.each{|v| print ",#{v}"}
			print "\n"
			nil
		else
			@name
		end
	end
end


# Defines a Deck of Vassals
class Deck
	include Heraldry

	def initialize
		@deck = Array.new
	end
	
	attr_accessor :deck
	
	def append(aVassal)
		@deck.push(aVassal)
		self
	end
	
	def [](key)
		@deck[key]
	end
	
	def inspect
		@deck.each {|v| v.inspect('t')}
	end
	
	# Deletes a vassal from the deck, by its location in the array
	def remove(vassPos)
		@deck.delete_at(vassPos)
	end
	
	# Gets a Vassals's position in the array, given its name
	def getPos(vassalName)
		@deck.each_with_index do |v,i|
			return i if v.name == vassalName
		end
	end
	
	# Writes the deck into a csv file
	def save
		#print "Enter a file name: "
		#filename = gets.chomp
		filename = "BIGTEST"
		print filename
		deckFile = File.new("#{filename}.txt", "w")
		@deck.each do |v|
			deckFile.puts(v.name + "," + v.blazon.join(","))
		end
	end
	
	# Reads a csv file and adds those vassals to the deck
	def load
		# FILL IN
	end
	
	# Compares the aspects of this vassal to another vassal and returns the similarity value.
	def compare(a, b)
		v1 = @deck[a]
		v2 = @deck[b]
		sim = 0
		v1.blazon.each {|k,v| sim += 1 if v == v2.blazon[k] && v != 0 }
		
		# Increments similarity for duplicate types, e.g. split fields and multiple charges
		sim += 1 if v1.blazon["Field A"] == v2.blazon["Field B"] && v1.blazon["Field A"] != 0 && v1.blazon["Field A"] != v2.blazon["Field A"]
		sim += 1 if v1.blazon["Charge A"] == v2.blazon["Charge B"] && v1.blazon["Charge A"] != 0 && v1.blazon["Charge A"] != v2.blazon["Charge A"]
		sim += 1 if v1.blazon["Charge A Tincture"] == v2.blazon["Charge B Tincture"] && v1.blazon["Charge A Tincture"] != 0 && v1.blazon["Charge A Tincture"] != v2.blazon["Charge A Tincture"]
		sim
	end
	
	# Calculates and returns the average connectivity of an individual with the rest of the deck
	def vassConnect
		# FILL IN
	end
	
	# Calculates and returns the average connectivity of the deck
	def deckConnect
		# FILL IN
	end
	
	# Recursive method for filling a Deck with all possible vassals.
	def fill_up
		i = 0
		
	end
	
	
	
	def fill_up(arr)
		if arr.length < BLAZ_TYPE.length
			BLAZ_TYPE[arr.length].keys.each do |k|
				fill_up(Array.new(arr << k))
				arr.pop
			end
		else
			testnum = 0
			arr.each_with_index { |n,i| testnum += n*10**(7-i)}
			@deck.push(Vassal.new("Test#{testnum}",arr))
			return
		end
	end		

end



puts "MAKING VASSALS"
#garcia = Vassal.new("Garcia",[1,1,2,1,2,3,4])
#vanW = Vassal.new("VanWeringh",[1,1,2,4,3,2,1])

puts "MAKING DECK"
deckTest = Deck.new
#deckTest.append(garcia)
#deckTest.append(vanW)

puts "FILLING DECK"
deckTest.fill_up([])

puts "SAVING DECK"
deckTest.save


#deckTest.inspect
#puts deckTest.compare(0,1)
#deckTest.remove(deckTest.getPos("Garcia"))

#target = open("Vtest.txt",'w')
#target.write(garcia.inspect)
#target.close

#NOTES from JP
# Add & subtract vassals at random to optimize
# JP: Consider using classes for all this

