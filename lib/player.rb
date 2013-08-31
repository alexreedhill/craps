class Player

	attr_writer :chip_count
	attr_writer :come_bets
	attr_accessor :pass_bet
	attr_accessor :pass_odds
	attr_accessor :pending_come_bet
	attr_accessor :winning_come_bet
	attr_accessor :come_odds

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

	def make_come_bet(amount)
		self.pending_come_bet = amount
		self.chip_count -= amount
	end

	def place_pass_odds
		self.pass_odds = 2 * pass_bet
		self.chip_count -= self.pass_odds
		return self
	end

	def place_come_odds(bet)
		bet[:odds] = 2 * bet[:amount]
		self.chip_count -= bet[:odds]
		return self
	end
end