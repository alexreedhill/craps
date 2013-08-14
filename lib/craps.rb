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
response = gets
puts "Awesome, let's get started."
#sleep(1.5)

def display_come_bets(come_bets)
	bets = []
	come_bets.each do |bet|
		bets << "| #{bet[:amount]} dollars on #{bet[:point]} |"
	end
	return bets.join
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
		player.chip_count += round.pass_line_payout(player, roll_result)
		puts "Congratulations! You just passed! Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
		if response == 'y'
			player.come_bets = []
			player.pass_bet = nil
			round = Round.new
			comeout_roll(player)
		else
			puts "You cashed out with $#{player.chip_count}!"
		end
	elsif roll_result == 7
		puts "Shoot! Seven out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		reponse = gets.chomp
		if reponse == 'y'
			comeout_roll(player)
		else
			puts "You cashed out with $#{player.chip_count}!"
		end
	else
		if player.pending_come_bet_amount
			player.come_bets = round.place_come_bet(player, roll_result)
			player.pending_come_bet_amount = nil
		end
		update_player = round.come_bet_payout(player, roll_result)
		player = update_player
		if player.winning_come_bet
			puts "You just won $#{player.winning_come_bet[:amount]} on your come bet on #{player.winning_come_bet[:point]}. Your new chip total is $#{player.chip_count}"
			sleep(2)
		end
		puts "Point is on #{round.point}. Your active come bets: #{display_come_bets(player.come_bets)}. Click enter to roll again"
		enter = gets
		point_roll(player, point, round)
	end
end

def come_bet_prompt(player, roll_result, round)
	puts "The point has been placed on #{roll_result}. Would you like you make a come bet? (y/n)"
	response = gets.chomp
	if response == 'y'
		puts "How much would you like you bet on the come?"
		come_bet = gets
		player.make_come_bet(come_bet.to_i)
		puts "You just placed a $#{player.pass_bet} bet on the come. Your new chip total is $#{player.chip_count}. Click enter to throw your next roll!"
		point_roll(player, roll_result, round)
	else
		puts 'Okay then. Click enter to throw your next roll!'
		point_roll(player, roll_result, round)
	end
end


def comeout_roll(player)
	player.come_bets = []
	player.pass_bet = nil
	round = Round.new
	puts "Pass line bet minimum is $5. How much would you like to bet?"
	pass_bet = gets
	player.make_pass_bet(pass_bet.to_i)

	puts "You just placed a $#{pass_bet} bet on the pass line. Your new chip total is $#{player.chip_count}. Click enter to throw your come out roll!"
	enter = gets
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
		if response == 'y'
			comeout_roll(player)
		else
			puts "You cashed out with $#{player.chip_count}!"
		end
	elsif roll_result == 2 || roll_result == 3 || roll_result == 12
		puts "Shoot! You crapped out. Your new chip total is $#{player.chip_count}. Would you like to play another round? (y/n)"
		response = gets.chomp
			if response == 'y'
				comeout_roll(player)
			else
				puts "You cashed out with $#{player.chip_count}!"
			end
	else
		come_bet_prompt(player, roll_result, round)
	end
end

comeout_roll(player)
