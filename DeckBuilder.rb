#!/usr/bin/env ruby

# Heraldy Module includes info about tinctures, charges, etc.
module Heraldry
	# These hashes help translate the Blazon from numbers into descriptions of the Vassal aspects.
	TINCTURES = ["Argent", "Or", "Sable", "Gules", "Azure"]
	ESCUTCHEONS = ["Iberian", "Swiss", "French"]
	CHARGES = ["Crescent", "Fleur-de-Lis", "Cross", "Rose", "Lion", "Eagle"]
end

# Defines a tincture, which is used to describe fields and charges.
class Tincture
	include Heraldry
	def initialize(tinc)
		@tinc = tinc if TINCTURES.include?(tinc)
	end
	
	def to_s
		@tinc
	end
	
	def compare(other)
		sim = 0
		sim += 1 if @tinc == other.tinc
		return sim
	end
	
	attr_accessor :tinc
end

# Defines an Escutcheon, the shape of the coat of arms.
class Escutcheon
	include Heraldry
	def initialize(esc)
		@esc = esc if ESCUTCHEONS.include?(esc)
	end
	
	def to_s
		@esc
	end
	
	def compare(other)
		sim = 0
		sim += 1 if @esc == other.esc
		return sim
	end
	
	attr_accessor :esc
end

# Defines a Field, the background of the coat of arms.
class Field
	include Heraldry
	def initialize(*tincs)
		@fields = []
		tincs.each{|t| @fields.push(Tincture.new(t))}
	end
	
	def add(*tincs)
		tincs.each{|t| @fields.push(Tincture.new(t))}
	end
	
	def split?
		@fields.length > 1
	end
	
	def to_s
		@fields.join(", ")
	end
		
	def compare(other)
		sim = 0
		@fields.each do |tA|
			other.fields.each {|tB| sim += tA.compare(tB)}
		end
		return sim
	end
	
	attr_accessor :fields
end

# Defines a Charge, a symbol which rests on the field and has a type and a tincture.
class Charge
	include Heraldry
	def initialize(type, tinc)
		@type = type if CHARGES.include?(type)
		@tinc = Tincture.new(tinc)
	end
	
	def to_s
		@type + " " + @tinc.to_s
	end
	
	def compare(other)
		sim = 0
		sim += 1 if @type == other.type
		sim += @tinc.compare(other.tinc)
		return sim
	end
	
	attr_accessor :type, :tinc
end

# Defines a Vassal
class Vassal
	include Heraldry
	
	# Initializes a new vassal
	def initialize(name, escutcheon, *blazon)
		@name = name if name.is_a?(String)
		@escutcheon = Escutcheon.new(escutcheon)
		@field = Field.new()
		@charges = []
		
		blazon.each_with_index do |arg, i|
			if TINCTURES.include?(arg) && charges.length == 0
				@field.add(arg)
			elsif CHARGES.include?(arg)
				@charges.push(Charge.new(arg,blazon[i+1]))
			end
		end
		
		# Arrays of unique charge attributes for comparison purposes:
		@chg_types = @charges.collect {|c| c.type}.uniq
		chg_tincs_str = @charges.collect {|c| c.tinc.to_s}.uniq
		@chg_tincs = chg_tincs_str.collect {|c| Tincture.new(c)}
	end

	# Attribute Accessors for all instance variables (e.g. vassal.name, vassal.name=)
	attr_accessor :name, :escutcheon, :field, :charges, :chg_types, :chg_tincs

	def to_s
		charge_str = @charges.collect {|c| c.to_s}
		"Name: #{@name}\n" + 
		"Escutcheon: #{@escutcheon.to_s}\n" + 
		"Field: #{@field.to_s}\n" + 
		"Charges: #{charge_str.join(", ")}\n"
	end
	
	def compare(other)
		sim = 0
		
		sim += @escutcheon.compare(other.escutcheon)
		sim	+= @field.compare(other.field)
		
		@chg_types.each do |typA|
			other.chg_types.each {|typB| sim += 1 if typA == typB}
		end
		
		@chg_tincs.each do |tncA|
			other.chg_tincs.each {|tncB| sim += tncA.compare(tncB)}
		end

		return sim
	end
end

# Defines a Deck of Vassals
class Deck
	include Heraldry

	def initialize
		@deck = Array.new
	end
	
	attr_accessor :deck
	
	# Adds a new vassal to the deck.
	def add(aVassal)
		@deck.push(aVassal)
		self
	end
	
	# Deletes a vassal from the deck, by its location in the array
	def remove(vassPos)
		@deck.delete_at(vassPos)
	end
		
	def [](key)
		@deck[key]
	end
	
	def to_s
		@deck.each {|v| v.to_s}
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
garcia = Vassal.new("Garcia", "Iberian", "Argent", "Or", "Eagle", "Sable", "Lion", "Azure")
vanW = Vassal.new("VanWeringh", "Iberian", "Argent", "Or", "Lion", "Sable", "Eagle", "Azure")
puts garcia.to_s
puts vanW.to_s
puts garcia.compare(vanW)
puts garcia.chg_types
puts garcia.chg_tincs

#vanW = Vassal.new("VanWeringh",[1,1,2,4,3,2,1])

#puts "MAKING DECK"
#deckTest = Deck.new
#deckTest.append(garcia)
#deckTest.append(vanW)

#puts "FILLING DECK"
#deckTest.fill_up([])

#puts "SAVING DECK"
#deckTest.save


#deckTest.inspect
#puts deckTest.compare(0,1)
#deckTest.remove(deckTest.getPos("Garcia"))

#target = open("Vtest.txt",'w')
#target.write(garcia.inspect)
#target.close

#NOTES from JP
# Add & subtract vassals at random to optimize
# JP: Consider using classes for all this

