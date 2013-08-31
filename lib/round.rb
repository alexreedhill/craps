class Round

	attr_accessor :roll_result
	attr_accessor :state
	attr_accessor :point
	attr_accessor :minimum

	PAYOUT_TABLE = {
	  4    => 2,
	  5    => 1.5,
	  6    => 1.2,
	  8    => 1.2,
	  9		 => 1.5,
	  10	 => 2
	}.freeze

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
		return roll
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

		place_come_bet(player, @roll_result) if player.pending_come_bet
		come_bet_payout(player, @roll_result, 'point')
		return @roll_result
	end

	def place_come_bet(player, roll_result)
		unless roll_result == 2 || roll_result == 3 || roll_result == 12
			come_bet = {:amount => player.pending_come_bet, :point => roll_result}
			player.come_bets = player.come_bets << come_bet
		end
		return player.come_bets
	end

	def pass_line_payout(player, roll_result)
		payout = (2 * player.pass_bet)
	end

	def pass_odds_payout(player, roll_result)
		payout = (player.pass_odds * PAYOUT_TABLE[roll_result]) + player.pass_odds
	end

	def come_bet_payout(player, roll_result, state)
		payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == roll_result
				payout += (bet[:amount] * PAYOUT_TABLE[bet[:point]]) + bet[:amount] unless roll_result == 11
				if state == :point
					payout += !!bet[:odds] ? (bet[:odds] * PAYOUT_TABLE[bet[:point]]) + bet[:odds] : 0
				elsif state == :comeout
					payout += bet[:odds] if bet[:odds]
				end
				player.winning_come_bet = {:amount => payout, :point => roll_result}
				player.come_bets.delete(bet)
				if player.pending_come_bet
					player.come_bets = player.come_bets << {:amount => player.pending_come_bet, :point => roll_result}
					player.pending_come_bet = nil
				end
				break
			end
		end
		player.chip_count += payout
		return player
	end

	def pending_come_bet_payout(player)
		payout = player.pending_come_bet * 2
	end

	def pass_win_payout(player, roll_result)
		payout = 0
		payout += pass_line_payout(player, roll_result)
		payout += pass_odds_payout(player, roll_result) if player.pass_odds
		payout += pending_come_bet_payout(player) if player.pending_come_bet
		return payout
	end

end