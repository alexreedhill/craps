require 'round'
require 'dice'
require 'player'

describe Round do
	let(:player) { Player.new }
	let(:round) { Round.new }

	it "should capture comeout roll between 2 and 12" do
		player.pass_bet = 5

	  round.comeout_roll(player)
	  round.roll_result.should be >= 2
	  round.roll_result.should be <= 12
	end

	it 'adds dice' do 

		player.pass_bet = 5
		Dice.any_instance.stub(:roll).and_return [5,6]

		round.comeout_roll(player)
		round.roll_result.should == 11
	end

	it 'is a player win if natural on comeout roll' do

		player.pass_bet = 5
	
		[[5,6], [3,4]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice 
	
			round.comeout_roll(player)
			round.state.should == 'natural'
		end
	end

	it 'is a player loss if craps on comeout roll' do
		[[1,1], [1,2], [6,6]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice

			round.comeout_roll(player)
			round.state.should == 'craps'
		end
	end

	it 'is a point round after comeout if other' do

		Dice.any_instance.stub(:roll).and_return [1,4]

		round.comeout_roll(player)
		round.state.should == 'point'
	end

	it 'places point on correct number' do

		Dice.any_instance.stub(:roll).and_return [1,1]

		round.comeout_roll(player)
		round.point == round.roll_result
	end


	it 'is a player win if point is hit' do

		Dice.any_instance.stub(:roll).and_return [4,4]

		player.pass_bet = 5
		round.point = 8
		round.point_roll(player)
		round.state.should == 'pass'
	end

	it 'is a player loss if seven-out' do

		Dice.any_instance.stub(:roll).and_return [3,4]

		round.point_roll(player)
		round.state.should == 'seven_out'
	end

	it 'pays correct amount on natural' do
		player.make_pass_bet(5)
		player.chip_count += round.pass_line_payout(player, 5)
		player.chip_count.should == 105

	end

	it 'pays correct amount on come bet' do

		player.come_bets = [{:amount => 5, :point => 8}]
		player.chip_count = 95
		update_player = round.come_bet_payout(player, 8)
		player = update_player
		player.chip_count.should == 106

	end

	it 'pays correct amount on pass' do 

		player.come_bets = [{:amount => 5, :point => 6}, {:amount => 10, :point => 8}]
		player.pass_bet = 10
		player.chip_count = 75
		player.chip_count += round.pass_win_payout(player, 6)
		player.chip_count.should == 128
	end

	it 'pays correct odds on 5,9 point bets' do
			player.pass_bet = 5
			player.come_bets = [{:amount => 5, :point => 5}]
			player.chip_count = 90
			player.chip_count += round.pass_win_payout(player, 5)
			player.chip_count.should == 112.5
	end

	it 'pays correct odds on 4, 10 point bets' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 5, :point => 4}]
		player.chip_count = 90
		player.chip_count += round.pass_win_payout(player, 4)
		player.chip_count.should == 115
	end

	it 'rejects come bet if 2,3,12' do
		[2,3,12].each do |roll_result|

			come_bets = round.place_come_bet(player, roll_result)
			come_bets.should == []
		end
	end

	it 'pays pass bet with odds' do
		player.pass_bet = 5
		player.pass_odds = 10
		player.chip_count = 85
		player.chip_count += round.pass_win_payout(player, 4)
		player.chip_count.should == 125
	end

	it 'pays single come bet with odds' do
		player.come_bets = [{:amount => 10, :point => 6, :odds => 20}]
		player.chip_count = 70
		update_player = round.come_bet_payout(player, 6)
		player = update_player
		player.chip_count.should == 136
	end

	it 'pays multiple come bets with odds on pass' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 10, :point => 9, :odds => 20}, 
												{:amount => 5, :point => 4, :odds => 10}]
		player.chip_count = 50
		player.chip_count += round.pass_win_payout(player, 6)
		player.chip_count.should == 180
	end

	it 'pays pending come bet on seven-out' do
		player.pending_come_bet = 5
		player.chip_count = 95
		player.chip_count += round.pending_come_bet_payout(player)
		player.chip_count.should == 105
	end

end