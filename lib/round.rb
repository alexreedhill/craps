class Round

	attr_accessor :roll_result
	attr_accessor :state
	attr_accessor :point
	attr_accessor :payout


	def comeout_roll(player)
		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == 7 || @roll_result == 11
			@state = 'natural'
			natural_payout(player.chip_count, player.pass_bet)
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

	def natural_payout(chip_count, amount)
		chip_count += (2 * amount.to_i)
	end

	def pass_bet_payout(player, roll_result, bet)
		if roll_result == 6 || roll_result == 8
			@payout = (bet * 1.2) + bet
		elsif roll_result == 5 || roll_result == 9
			@payout = (bet * 1.5) + bet
		elsif roll_result == 4 || roll_result == 10
			@payout = (bet * 2) + bet	
		end
	end

	def come_bet_payout(player, roll_result)
		@payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == roll_result
				if bet[:point] == 6 || bet[:point] == 8
					@payout = (bet[:amount] * 1.2) + bet[:amount]
				elsif bet[:point] == 5 || bet[:point] == 9
					@payout = (bet[:amount] * 1.5) + bet[:amount]
				elsif bet[:point] == 4 || bet[:point] == 10
					@payout += (bet[:amount] * 2) + bet[:amount]
				end
			end
		end
		return @payout
	end

	def pay_all_come_bets(player)
		@payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == 6 || bet[:point] == 8
				@payout += (bet[:amount] * 1.2) + bet[:amount]
			elsif bet[:point] == 5 || bet[:point] == 9
				@payout += (bet[:amount] * 1.5) + bet[:amount]
			elsif bet[:point] == 4 || bet[:point] == 10
				@payout += (bet[:amount] * 2) + bet[:amount]
			end
		end
		return @payout
	end

	def pass_win_payout(player, roll_result)
		@payout = 0
		@payout += pass_bet_payout(player, roll_result, player.pass_bet)
		@payout += pass_bet_payout(player, roll_result, player.pass_odds) if player.pass_odds
		@payout += pay_all_come_bets(player)
		return @payout
	end

end