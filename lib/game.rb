require 'dice'

class Game

	attr_accessor :first_roll_result


	def make_first_roll
		roll = Dice.new.roll
		@first_roll_result = roll[0] + roll[1]
	end

end