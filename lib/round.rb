class Round

	attr_accessor :roll_result
	attr_accessor :state
	attr_accessor :point
	attr_accessor :payout

	PAYOUT_TABLE = {
	  4    => 2,
	  5    => 1.5,
	  6    => 1.2,
	  8    => 1.2,
	  9		 => 1.5,
	  10	 => 2
	}.freeze

	def initialize
		@payout = 0
	end	

	def comeout_roll(player)
		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == 7 || @roll_result == 11
			@state = 'natural'
			pass_line_payout(player, @roll_result)
		elsif @roll_result == 2 || @roll_result == 3 || @roll_result == 12
			@state = 'craps'
		else 
			@state = 'point'
		end

		@point = @roll_result
	end

	def point_roll(player)
		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == @point
			@state = 'pass'
		elsif @roll_result == 7 
			@state = 'seven_out'
		end

		if @state == 'pass'
			pass_win_payout(player, @roll_result)
		end

		place_come_bet(player, @roll_result) if player.pending_come_bet_amount
		come_bet_payout(player, @roll_result)
		return @roll_result
	end

	def place_come_bet(player, roll_result)
		unless roll_result == 2 || roll_result == 3 || roll_result == 12
			come_bet = {:amount => player.pending_come_bet_amount, :point => roll_result}
			player.come_bets = player.come_bets << come_bet
		end
		return player.come_bets
	end

	def pass_line_payout(player, roll_result)
		@payout = 0
		@payout = (2 * player.pass_bet)
	end

	def pass_odds_payout(player, roll_result)
		@payout = 0
		@payout = (player.pass_odds * PAYOUT_TABLE[roll_result]) + player.pass_odds
	end

	def come_bet_payout(player, roll_result)
		@payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == roll_result
				@payout = (bet[:amount] * PAYOUT_TABLE[bet[:point]]) + bet[:amount]
				@payout += (bet[:odds] * PAYOUT_TABLE[bet[:point]]) + bet[:odds] if bet[:odds]
			end
		end
		return @payout
	end

	def pay_all_come_bets(player)
		@payout = 0
		player.come_bets.each do |bet|
			@payout += (bet[:amount] * PAYOUT_TABLE[bet[:point]]) + bet[:amount]
			@payout += (bet[:odds] * PAYOUT_TABLE[bet[:point]]) + bet[:odds] if bet[:odds]
		end
		return @payout
	end

	def pass_win_payout(player, roll_result)
		@payout += pass_line_payout(player, roll_result)
		@payout += pass_odds_payout(player, roll_result) if player.pass_odds
		@payout += pay_all_come_bets(player)
		return @payout
	end

end