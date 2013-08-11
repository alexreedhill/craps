class Round

	attr_accessor :roll_result
	attr_accessor :state
	attr_accessor :point
	attr_accessor :payout


	def comeout_roll(player)
		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == 7 || @roll_result == 11
			@state = 'player_win_natural'
			natural_payout(player.chip_count, player.pass_bet)
		elsif @roll_result == 2 || @roll_result == 3 || @roll_result == 12
			@state = 'player_loss_craps'
		else 
			@state = 'point'
		end

		@point = @roll_result
	end

	def point_roll(player)
		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == @point
			@state = 'player_win_point'
		elsif @roll_result == 7 
			@state = 'player_loss_point'
		end

		if @state == 'player_win_point'
			player_point_win_payout(player, @roll_result)
		end

		place_come_bet(player, @roll_result) if player.pending_come_bet_amount
		come_bet_payout(player, @roll_result)
		return @roll_result
	end

	def place_come_bet(player, roll_result)
		player.come_bets = [{:amount => player.pending_come_bet_amount, :point => roll_result}]
		return player.come_bets
	end

	def natural_payout(chip_count, amount)
		chip_count += (2 * amount.to_i)
	end

	def pass_bet_payout(player, roll_result)
		bet = player.pass_bet
		if roll_result == 6 || roll_result == 8
			@payout = (bet * 1.2).round + bet
		end
	end

	def come_bet_payout(player, roll_result)
		@payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == roll_result
				if bet[:point] == 6 || bet[:point] == 8
					@payout = (bet[:amount] * 1.2).round + bet[:amount]
				end
			end
		end
		return @payout
	end

	def pay_all_come_bets(player)
		@payout = 0
		player.come_bets.each do |bet|
			if bet[:point] == 6 || bet[:point] == 8
				@payout += (bet[:amount] * 1.2).round + bet[:amount]
			end
		end
		return @payout
	end

	def player_point_win_payout(player, roll_result)
		@payout = 0
		@payout += pass_bet_payout(player, roll_result)
		@payout += pay_all_come_bets(player)
		return @payout
	end

end