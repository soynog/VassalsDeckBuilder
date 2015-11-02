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

	def metal?
		(@tinc == "Argent") || (@tinc == "Or")
	end

	def color?
		(@tinc == "Gules") || (@tinc == "Azure")
	end
	
	def compare(other)
		sim = 0
		sim += 1 if @tinc == other.tinc
		return sim
	end

	def contrast?(other)
		!(self.metal? && other.metal?) && !(self.color? && other.color?) && !(@tinc == other.tinc)
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

	def to_s(mode=1)
		charge_str = @charges.collect {|c| c.to_s}
		case mode
		when 1
			"#{@name}: escutcheon #{@escutcheon.to_s}; field(s) #{@field.to_s}; charge(s) #{charge_str.join(", ")}."
		when 2	
			"#{@name}\n" + 
			"Escutcheon: #{@escutcheon.to_s}\n" + 
			"Field: #{@field.to_s}\n" + 
			"Charges: #{charge_str.join(", ")}\n"
		else
			@name
		end
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

	# Method for generating a random, well-formed vassal
	def self.random(name="RandomVassal",num_fields=1,num_chg_types=1,num_chg_tincs=1,escAry=Array.new(ESCUTCHEONS), \
			fldAry=Array.new(TINCTURES),chgTypeAry=Array.new(CHARGES),chgTincAry=Array.new(TINCTURES))

		blazon = []
		fldAry.sample(num_fields).each {|f| blazon.push(f)}

		chgTincAry.keep_if {|t| Tincture.new(t).contrast?(Tincture.new(blazon[0]))} if num_fields == 1

		if num_chg_types == 1 && num_chg_tincs == 1
			chgTincAry.keep_if {|t| !blazon.include?(t)} if num_fields == 2
			chgType = chgTypeAry.sample
			chgTinc = chgTincAry.sample
			blazon.push(chgType)
			blazon.push(chgTinc)
		else
			if num_chg_types == 1 then chgA_type = chgB_type = chgTypeAry.sample end
			if num_chg_types == 2 then chgA_type,chgB_type = chgTypeAry.sample(2) end

			chgTincAry_1 = chgTincAry.select {|t| Tincture.new(t).contrast?(Tincture.new(blazon[0]))}
			chgTincAry_2 = chgTincAry.select {|t| Tincture.new(t).contrast?(num_fields == 2 ? Tincture.new(blazon[1]) : Tincture.new(blazon[0]))}

			chgA_tinc = chgTincAry_1.sample
			chgTincAry_2.delete(chgA_tinc)
			chgB_tinc = num_chg_tincs == 2 ? chgTincAry_2.sample : chgA_tinc

			blazon.push(chgA_type)
			blazon.push(chgA_tinc)
			blazon.push(chgB_type)
			blazon.push(chgB_tinc)
		end

		return Vassal.new(name,escAry.sample,*blazon)
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
		@deck.each {|v| "#{v.to_s}\n"}
	end

	def length
		@deck.length
	end
	
	# Gets a Vassals's position in the array, given its name
	def getPos(vassalName)
		@deck.each_with_index do |v,i|
			return i if v.name == vassalName
		end
	end
	
	# Writes the deck into a file
	def save(fname)
		filename = fname
		puts "Saving #{filename}"
		deckFile = File.new("#{filename}.txt", "w")
		deckFile.puts(self.to_s)
	end
	
	# Reads a csv file and adds those vassals to the deck
	def load
		# FILL IN
	end
	
	# Returns an array of the vassal's connectivity to the other vassals in the deck.
	def connectivity(vassal)
		connAry = []
		@deck.each do |v|
			connAry << vassal.compare(v) unless vassal == v 
		end
		return connAry
	end

	# Fills deck with a random assortment of cards based on defined restrictions and targets
	# deck_size is the target total size of the deck
	# max_conn is the maximum level of connectivity allowable between any two cards
	# conn_targ is the target minimum average level of connectivity
	# asp_toler is amount of imbalance allowed between the count one aspect and any other aspect of the same class (i.e. # of each escutcheon type, etc.)
	# split_prop is the proportion of the deck that will have split fields
	# dblchg_prop is the proportion of the deck that will have two charges
	def self.randomFill(deck_size=20,max_conn=4,conn_targ=1.0,asp_toler=1,split_prop=0.5,dblchg_prop=0.5)
		randomDeck = Deck.new
		escut_count = Hash[ESCUTCHEONS.collect {|e| [e,0]}]
		fld_count = Hash[TINCTURES.collect {|t| [t,0]}]
		chgType_count = Hash[CHARGES.collect {|c| [c,0]}]
		chgTinc_count = Hash[TINCTURES.collect {|t| [t,0]}]

		while randomDeck.length < deck_size
			# generate allowable aspect arrays
			escAry = (escut_count.select {|k,v| v <= (escut_count.values.min + asp_toler)}).keys
			fldAry = (fld_count.select {|k,v| v <= (fld_count.values.min + asp_toler)}).keys
			chgTypeAry = (chgType_count.select {|k,v| v <= (chgType_count.values.min + asp_toler)}).keys
			chgTincAry = (chgTinc_count.select {|k,v| v <= (chgTinc_count.values.min + asp_toler)}).keys
			
			# add a random vassal using allowable aspect arrays as inputs
			newVass = Vassal.random("RandomHouse",1,1,1,escAry,fldAry,chgTypeAry,chgTincAry)
			randomDeck.add(newVass)
			puts newVass.to_s


			# check stats and determine if vassal is acceptable

			# if acceptable, update stats and allowable aspect arrays
			escut_count[newVass.escutcheon.to_s] += 1
			newVass.field.fields.each {|f| fld_count[f.to_s] += 1}
			newVass.chg_types.each {|c| chgType_count[c] += 1}
			newVass.chg_tincs.each {|t| chgTinc_count[t.to_s] += 1}

			puts escut_count
			puts fld_count
			puts chgType_count
			puts chgTinc_count
		end

		return randomDeck
	end

end



rando = Deck.randomFill