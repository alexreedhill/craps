require 'round'
require 'dice'
require 'player'

describe Round do
	let(:round) { Round.new }
	let(:player) { Player.new }

	it "should capture comeout roll between 2 and 12" do
	  round.comeout_roll(player)
	  round.roll_result.should be >= 2
	  round.roll_result.should be <= 12
	end

	it 'adds dice' do 
		
		Dice.any_instance.stub(:roll).and_return [5,6]

		round.comeout_roll(player)
		round.roll_result.should == 11
	end

	it 'is a player win if natural on comeout roll' do
	
		[[5,6], [3,4]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice 
	
			round.comeout_roll(player)
			round.state.should == 'player_win_natural'
		end
	end

	it 'is a player loss if craps on comeout roll' do
		[[1,1], [1,2], [6,6]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice

			round.comeout_roll(player)
			round.state.should == 'player_loss_craps'
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
		round.state.should == 'player_win_point'
	end

	it 'is a player loss if seven-out' do

		Dice.any_instance.stub(:roll).and_return [3,4]

		round.point_roll(player)
		round.state.should == 'player_loss_point'
	end

	it 'pays correct amount on natural' do
		player.make_line_bet('pass', 5)
		round.state = 'player_win_natural'
		player.chip_count = round.natural_payout(player.chip_count, 5)
		player.chip_count.should == 105

	end

	it 'pays correct amount on come bet' do

		player.come_bets = [{:amount => 5, :point => 8}]
		player.chip_count = 95
		player.chip_count += round.come_bet_payout(player, 8)
		player.chip_count.should == 106

	end

	it 'pays correct amount on player win' do 

		player.come_bets = [{:amount => 5, :point => 6}, {:amount => 10, :point => 8}]
		player.pass_bet = 10
		player.chip_count = 75
		player.chip_count += round.player_point_win_payout(player, 6)
		player.chip_count.should == 130
	end

	it 'pays correct odds on 5,9 point bets' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 5, :point => 5}]
		player.chip_count = 90
		player.chip_count += round.player_point_win_payout(player, 5)
		player.chip_count.should == 115
	end

	it 'pays correct odds on 4, 10 point bets' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 5, :point => 4}]
		player.chip_count = 90
		player.chip_count += round.player_point_win_payout(player, 4)
		player.chip_count.should == 120
	end

end