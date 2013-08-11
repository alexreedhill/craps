class Player

	attr_writer :chip_count
	attr_writer :come_bets
	attr_accessor :pass_bet
	attr_accessor :pending_come_bet_amount

	def chip_count
		@chip_count || 100
	end

	def come_bets
		@come_bets || []
	end

	def make_line_bet(type, amount)
		@pass_bet = {type => amount}
		self.chip_count -= amount
	end

	def make_come_bet(amount) #TODO Bet should be returned to you if you hit the point
		@pending_come_bet_amount = amount
	end

end