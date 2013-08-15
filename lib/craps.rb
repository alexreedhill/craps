load 'lib/dice.rb'
load 'lib/round.rb'
load 'lib/player.rb'

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
				-----",
}

player = Player.new

puts 'Hey friend, are you ready to play some craps?'
response = gets.chomp
puts "Awesome, let's get started."
sleep(1)

def display_come_bets(player)
	bets = []
	player.come_bets.each do |bet|
		bets = bets << "| $#{bet[:amount]} on #{bet[:point]} odds: #{"yes" if bet[:odds] == 10}#{"no" if bet[:odds] == nil} | "
	end
	return bets.join
end


def enforce_minimum(player, bet, phase, point, round)
	if bet < round.minimum
		if phase == 'comeout'
			puts "You must bet the minimum."
			sleep(1)
			player.pass_bet = nil
			comeout_roll(player)
		elsif phase == 'point'
			puts 'You must bet the minimum.'
			player.pending_come_bet_amount = nil
			sleep(1)
			come_bet_prompt(player, point, round, true)
		else
			point_roll(player, point, round)
		end
	end
end

def odds_prompt(player, point, round)
	puts "Would you like to place odds on your pass or come bets? (pass/come/n)"
	response = gets.chomp
	if response == 'pass'
		update_player = player.place_pass_odds
		player = update_player
		puts "You have placed $#{player.pass_odds} odds on #{round.point}."
		sleep(1)
		odds_prompt(player, point, round)
	elsif response == 'come'
		puts "Your active come bets: #{display_come_bets(player)}"
		sleep(1)
		puts "Which come bet would you like to place odds on? (1-#{player.come_bets.count})"
		response = gets.chomp.to_i - 1
		bet = player.come_bets[response]
		player = player.place_come_odds(bet)
		puts "You just placed $#{bet[:odds]} odds on #{bet[:point]}."
		sleep(1)
		odds_prompt(player, point, round)
	else
		puts "Okay then. Click enter to throw your next roll!"
		enter = gets.chomp
	end 
end

def cashout_prompt(player, response)
	unless response == 'n'
		comeout_roll(player)
	else
		puts "You cashed out with $#{player.chip_count}!"
		abort
	end
end

def point_roll(player, point, round)
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
	
	if roll_result == point
		round.state = 'pass'
		player.chip_count += round.pass_win_payout(player, roll_result)
		puts "Congratulations! You just passed! Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
		cashout_prompt(player, response)
	elsif roll_result == 7
		puts "Shoot! Seven out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
		cashout_prompt(player, response)
	else
		update_player = round.come_bet_payout(player, roll_result)
		player = update_player
		if player.winning_come_bet
			puts "You just won $#{player.winning_come_bet[:amount]} on your come bet on #{player.winning_come_bet[:point]}. Your new chip total is $#{player.chip_count}"
			sleep(2)
		end
		if player.pending_come_bet_amount
			player.come_bets = round.place_come_bet(player, roll_result)
			player.pending_come_bet_amount = nil
		end
		puts "Point is on #{round.point}. Your active come bets: #{display_come_bets(player)}  Your chip total is $#{player.chip_count}."
		sleep(1)
		come_bet_prompt(player, round.point, round, false)
		odds_prompt(player, point, round)
	end
end

def come_bet_prompt(player, point, round, skip)
	response = 'y'
	if skip == false
		puts "Would you like you make a come bet? (y/n)"
		response = gets.chomp
	end
	if response == 'y'
		puts "How much would you like you bet on the come?"
		come_bet = gets.chomp
		enforce_minimum(player, come_bet.to_i, 'point', point, round)
		player.chip_count = player.make_come_bet(come_bet.to_i)
		puts "You just placed a $#{come_bet} bet on the come."
		sleep(1)
		odds_prompt(player, point, round)
		point_roll(player, point, round)
	else
		odds_prompt(player, point, round)
		enter = gets
		point_roll(player, point, round)
	end
end

def comeout_roll(player)
	player.come_bets = []
	player.pass_bet = nil
	round = Round.new
	round.minimum = 5
	puts "Pass line bet minimum is $5. How much would you like to bet?"
	pass_bet = gets.chomp
	enforce_minimum(player, pass_bet.to_i, 'comeout', nil, round)
	player.make_pass_bet(pass_bet.to_i)
	puts "You just placed a $#{pass_bet} bet on the pass line. Your new chip total is $#{player.chip_count}. Click enter to throw your come out roll!"
	enter = gets.chomp
	puts "Rolling the dice..."
	dice = Dice.new.roll
	roll_result = dice[0] + dice[1]
	round.point = roll_result
	10.times do 
		puts DICE[rand(1..6)] + DICE[rand(1..6)]
		sleep(0.05)
	end
	puts DICE[dice[0]] + DICE[dice[1]]
	puts "You rolled a #{dice[0]} and a #{dice[1]} for a total of #{roll_result}"
	
	if roll_result == 7 || roll_result == 11
		round.state = 'natural'
		player.chip_count += round.pass_line_payout(player, roll_result)
		puts "Congratulations! You just rolled a natural! Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
		cashout_prompt(player, response)
	elsif roll_result == 2 || roll_result == 3 || roll_result == 12
		puts "Shoot! You crapped out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
		cashout_prompt(player, response)
	else
		come_bet_prompt(player, roll_result, round, false)
		odds_prompt(player, point, round)
	end
end

comeout_roll(player)
