load 'lib/dice.rb'
load 'lib/round.rb'
load 'lib/player.rb'



class Craps
	DICE = {
		1 => "
					-----
					|   |
					| o |
					|   |
					-----",
		2 => "
					-----
					|o  |
					|   |
					|  o|
					-----",
		3 => "
					-----
					|o  |
					| o |
					|  o|
					-----",
		4 => "
					-----
					|o o|
					|   |
					|o o|
					-----",
		5 => "
					-----
					|o o|
					| o |
					|o o|
					-----",
		6 => "
					-----
					|o o|
					|o o|
					|o o|
					-----"
	}

	def intro(player)	
		puts 'Hey friend, are you ready to play some craps?'
		response = gets.chomp
		puts "Awesome, let's get started."
		sleep(1)
		new_round(player)
	end
	
	def display_come_bets(player)
		bets = []
		player.come_bets.each do |bet|
			bets = bets << "| $#{bet[:amount]} on #{bet[:point]} odds: #{bet[:odds] == bet[:amount] * 2 ? 'yes' : 'no'} | "
		end
		return player.come_bets == [] ? 'none ' : bets.join
	end
	
	def enforce_minimum(player, bet, phase, round)
		if bet < round.minimum
			if phase == :comeout
				puts "You must bet the minimum."
				sleep(1)
				player.pass_bet = nil
				new_round(player)
			elsif phase == :point
				puts 'You must bet the minimum.'
				player.pending_come_bet = nil
				sleep(1)
				come_bet_prompt(player, round, true)
			else
				point_roll(player, round)
			end
		end
	end

	def enforce_pass_odds(player, round)
		if !!player.pass_odds
			puts 'You have already placed odds on your pass line bet.'
			sleep(1) 
			odds_prompt(player, round)
		end
	end

	def enforce_come_odds(player, round, bet)
		if !!bet[:odds]
			puts 'You have already placed odds on this come bet.'
			sleep(1) 
			come_odds_prompt(player, round)
		end
	end

	def pass_odds_prompt(player, round)
		enforce_pass_odds(player, round)
		update_player = player.place_pass_odds
		player = update_player
		puts "You have placed $#{player.pass_odds} odds on #{round.point}."
		sleep(1)
		odds_prompt(player, round)
	end

	def come_odds_prompt(player, round)
		puts "Your active come bets: #{display_come_bets(player)}"
		sleep(1)
		puts "Which come bet would you like to place odds on? (1-#{player.come_bets.count} or n)"
		response = gets.chomp
		if response.to_i.between?(1, player.come_bets.count)
			bet = player.come_bets[response.to_i - 1]
			enforce_come_odds(player, round, bet)
			player = player.place_come_odds(bet)
			puts "You just placed $#{bet[:odds]} odds on #{bet[:point]}."
			sleep(1)
		elsif response == 'n'
			odds_prompt(player, round)
		else
			puts 'Invalid entry. Please try again.'
			come_odds_prompt(player, round)
		end
		odds_prompt(player, round)
	end
	
	def odds_prompt(player, round)
		come_bets = player.come_bets
		come_odds = come_bets.collect { |bet| bet[:odds] }
		come_odds = [nil] if come_odds == []
		unless !!player.pass_odds && come_odds.compact.count == come_bets.count
			puts "Would you like to place odds on your pass or come bets? (pass/come/n)"
			response = gets.chomp
			if response == 'pass'
				pass_odds_prompt(player, round)
			elsif response == 'come'
				come_odds_prompt(player, round)
			end
		end
	end
	
	def cashout_prompt(player)
		response = gets.chomp
		unless response == 'n'
			new_round(player)
		else
			puts "You cashed out with $#{player.chip_count}!"
			abort
		end
		return response
	end

	def pass(player, roll_result, round)
		player.chip_count += round.pass_win_payout(player, roll_result)
		puts "Congratulations! You just passed! Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		cashout_prompt(player)
	end

	def seven_out(player, roll_result, round)
		player.chip_count += round.pending_come_bet_payout(player) if player.pending_come_bet
		player.come_bets = []
		puts "Shoot! Seven out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		cashout_prompt(player)
	end

	def next_roll(player, round)
		puts "Okay then. Click enter to throw your next roll!"
		enter = gets.chomp
		point_roll(player, round)
	end

	def service_come_bets(player, roll_result, round)
		update_player = round.come_bet_payout(player, roll_result, :point)
		player = update_player
		if player.winning_come_bet
			puts "You just won $#{player.winning_come_bet[:amount]} on your come bet on #{player.winning_come_bet[:point]}. Your new chip total is $#{player.chip_count}"
			sleep(2)
		end
		if player.pending_come_bet
			player.come_bets = round.place_come_bet(player, roll_result)
			player.pending_come_bet = nil
		end
	end

	def point_roll_result(player, roll_result, round)
		if roll_result == round.point
			pass(player, roll_result, round)
		elsif roll_result == 7
			seven_out(player, roll_result, round)
		else
			service_come_bets(player, roll_result, round)
			puts "Point is on #{round.point}. Your active come bets: #{display_come_bets(player)}  Your chip total is $#{player.chip_count}."
			sleep(1)
			odds_prompt(player, round)
			come_bet_prompt(player, round, false)
		end	
	end

	def pass_bet_prompt(player, round)
		puts "Pass line bet minimum is $5. How much would you like to bet?"
		pass_bet = gets.chomp
		enforce_minimum(player, pass_bet.to_i, :comeout, round)
		player.make_pass_bet(pass_bet.to_i)
		return pass_bet
	end

	def natural(player, roll_result, round)
		player.chip_count += round.pass_line_payout(player, roll_result)
		puts "Congratulations! You just rolled a natural! Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		cashout_prompt(player)
	end

	def craps(player, roll_result, round)
		puts "Shoot! You crapped out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		cashout_prompt(player)
	end
	
	def point_roll(player, round)
		player.winning_come_bet = nil
		puts "Rolling the dice..."
		dice = Dice.new.roll
		roll_result = dice[0] + dice[1]
		10.times do 
			puts DICE[rand(1..6)] + DICE[rand(1..6)]
			sleep(0.05)
		end
		puts DICE[dice[0]] + DICE[dice[1]]
		puts "You rolled a #{dice[0]} and a #{dice[1]} for a total of #{roll_result}"
		
		point_roll_result(player, roll_result, round)
	end

	def come_bet_amount_prompt(player, round)
		puts "How much would you like you bet on the come?"
		come_bet = gets.chomp
		enforce_minimum(player, come_bet.to_i, :point, round)
		player.chip_count = player.make_come_bet(come_bet.to_i)
		puts "You just placed a $#{come_bet} bet on the come."
	end
	
	def come_bet_prompt(player, round, skip)
		response = 'y'
		if skip == false
			puts "Would you like you make a come bet? Your active come bets: #{display_come_bets(player)}(y/n)"
			response = gets.chomp
		end
		if response == 'y'
			come_bet_amount_prompt(player, round)
			sleep(1)
			next_roll(player, round)
		else
			next_roll(player, round)
		end
	end

	def new_round(player)
		player.pass_bet = nil
		player.pass_odds = nil
		player.pending_come_bet = nil
		player.winning_come_bet = nil
		round = Round.new
		round.minimum = 5
		pass_bet = pass_bet_prompt(player, round)
		puts "You just placed a $#{pass_bet} bet on the pass line. Your new chip total is $#{player.chip_count}. Click enter to throw your come out roll!"
		enter = gets.chomp
		comeout_roll(player, round)
	end

	def comeout_roll_result(player, dice, roll_result, round)
		puts "You rolled a #{dice[0]} and a #{dice[1]} for a total of #{roll_result}"
		if roll_result == 7 || roll_result == 11
			natural(player, roll_result, round)
		elsif roll_result == 2 || roll_result == 3 || roll_result == 12
			craps(player, roll_result, round)
		else
			odds_prompt(player, round)
			come_bet_prompt(player, round, false)
		end
	end
	
	def comeout_roll(player, round)
		puts "Rolling the dice..."
		dice = Dice.new.roll
		roll_result = dice[0] + dice[1]
		round.point = roll_result
		10.times do 
			puts DICE[rand(1..6)] + DICE[rand(1..6)]
			sleep(0.05)
		end
		puts DICE[dice[0]] + DICE[dice[1]]
		comeout_roll_result(player, dice, roll_result, round)
	end

end

player = Player.new
craps = Craps.new

craps.intro(player)
