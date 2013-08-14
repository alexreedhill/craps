class Player

	attr_writer :chip_count
	attr_writer :come_bets
	attr_accessor :pass_bet
	attr_accessor :pass_odds
	attr_accessor :pending_come_bet_amount
	attr_accessor :winning_come_bet

	def chip_count
		@chip_count || 100
	end

	def come_bets
		@come_bets || []
	end

	def make_pass_bet(amount)
		@pass_bet = amount
		self.chip_count -= amount
	end

	def make_come_bet(amount) #TODO Bet should be returned to you if you hit the point
		self.pending_come_bet_amount = amount
		self.chip_count -= amount
	end

	def place_pass_odds
		@pass_odds = 2 * pass_bet
	end

	def place_come_odds(bet)
		bet[:odds] = 2 * bet[:amount]
	end
end