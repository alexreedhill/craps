require 'dice'

describe Dice do
	
	it "returns 2 numbers between 1-6 in an array" do
		roll = Dice.new.roll
		roll.each do |die|
			die.should be >= 1
			die.should be <= 6
		end
	end
end