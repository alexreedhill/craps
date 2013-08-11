load 'lib/dice.rb'
load 'lib/round.rb'
load 'lib/player.rb'



dice = Dice.new
round = Round.new
player = Player.new

puts 'Hey friend, are you ready to play some craps?'
response = gets

puts "Awesome, let's get started. Pass line bet minimum is $5. How much would you like to bet?"
pass_bet = gets
player.make_pass_bet(pass_bet.to_i)

puts "You just placed a $#{player.pass_bet} bet on the pass line. Your new chip total is $#{player.chip_count}. Click enter to throw your come out roll!"
enter = gets
puts "Rolling the dice..."
dice = Dice.new.roll
roll_result = dice[0] + dice[1]

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
puts DICE[dice[0]] + DICE[dice[1]]
puts "You rolled a #{dice[0]} and a #{dice[1]} for a total of #{roll_result}"

if roll_result == 7 || roll_result == 11
	round.state = 'natural'
	player.chip_count += round.pass_line_payout(player, roll_result)
	puts "Congratulations! You just rolled a natural! Your new chip total is #{player.chip_count}"
elsif roll_result == 2 || roll_result == 3 || roll_result == 12
	puts "Shoot! You crapped out. Your new chip total is #{player.chip_count}. Would you like to play another round?"
else
	puts "The point has been placed on #{roll_result}. Would you like you make a come bet? (yes/no)"
	binary_response = gets
end

if round.state == 'natural'
	puts 'Would you like to play another round? (yes/no)'
	response = gets
	if response == 'yes'
		initialize
	end
end

if binary_response == 'yes'
	puts "How much would you like you bet on the come?"
	come_bet = gets
	player.make_come_bet(come_bet.to_i)
	puts "You just placed a $#{player.pass_bet} bet on the come. Your new chip total is $#{player.chip_count}. Click enter to throw your next roll!"
end

response = gets

puts DICE[dice[0]] + DICE[dice[1]]
puts "You rolled a #{dice[0]} and a #{dice[1]} for a total of #{roll_result}"

if roll_result == 7 || roll_result == 11
	round.state = 'natural'
	player.chip_count += round.pass_line_payout(player, roll_result)
	puts "Congratulations! You just rolled a natural! Your new chip total is #{player.chip_count}"
elsif roll_result == 2 || roll_result == 3 || roll_result == 12
	puts "Shoot! You crapped out. Your new chip total is #{player.chip_count}. Would you like to play another round?"
else
	puts "The point has been placed on #{roll_result}. Would you like you make a come bet? (yes/no)"
	binary_response = gets
end

if round.state == 'natural'
	puts 'Would you like to play another round? (yes/no)'
	response = gets
	if response == 'yes'
		initialize
	end
end

if binary_response == 'yes'
	puts "How much would you like you bet on the come?"
	come_bet = gets
	player.make_come_bet(come_bet.to_i)
	puts "You just placed a $#{player.pass_bet} bet on the come. Your new chip total is $#{player.chip_count}. Click enter to throw your next roll!"
end



