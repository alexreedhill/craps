class Round

	attr_accessor :roll_result
	attr_accessor :state
	attr_accessor :point


	def comeout_roll
		@state = 'comeout'

		roll = Dice.new.roll
		@roll_result = roll[0] + roll[1]

		if @roll_result == 7 || @roll_result == 11
			@state = 'player_win_natural'
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
			@state = 'player_win'
		elsif @roll_result == 7 
			@state = 'player_loss'
		end

		place_come_bet(player, @roll_result) if player.pending_come_bet_amount
		come_bet_payout(player, @roll_result)
		return @roll_result
	end

	def place_come_bet(player, roll_result)
		player.come_bets = [{:amount => player.pending_come_bet_amount, :point => roll_result}]
		return player.come_bets
	end

	def pass_bet_payout(chip_count, amount)
		if @state == 'player_win_natural'
			chip_count = chip_count + (2 * amount)
		end

		return chip_count
	end

	def come_bet_payout(player, roll_result)
		player.come_bets.each do |bet|
			if roll_result == bet[:point]
				if roll_result == 6 || roll_result == 8
					player.chip_count += (bet[:amount].to_f * 1.2)
				end
			end
		end
		return player.chip_count
	end

end