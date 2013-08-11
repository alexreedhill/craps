require 'round'
require 'dice'
require 'player'

describe Round do
	let(:round) { Round.new }
	let(:player) { Player.new }

	it "should capture comeout roll between 2 and 12" do
	  round.comeout_roll
	  round.roll_result.should be >= 2
	  round.roll_result.should be <= 12
	end

	it 'adds dice' do 
		
		Dice.any_instance.stub(:roll).and_return [5,6]

		round.comeout_roll
		round.roll_result.should == 11
	end

	it 'is a player win if natural on comeout roll' do
	
		[[5,6], [3,4]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice 
	
			round.comeout_roll
			round.state.should == 'player_win_natural'
		end
	end

	it 'is a player loss if craps on comeout roll' do
		[[1,1], [1,2], [6,6]].each do |dice|
			Dice.any_instance.stub(:roll).and_return dice

			round.comeout_roll
			round.state.should == 'player_loss_craps'
		end
	end

	it 'is a point round after comeout if other' do

		Dice.any_instance.stub(:roll).and_return [1,4]

		round.comeout_roll
		round.state.should == 'point'
	end

	it 'places point on correct number' do

		Dice.any_instance.stub(:roll).and_return [1,1]

		round.comeout_roll
		round.point == round.roll_result
	end

	it 'is a player win if point is hit' do

		Dice.any_instance.stub(:roll).and_return [1,2]

		round.point = 3
		round.point_roll(player)
		round.state.should == 'player_win'
	end

	it 'is a player loss if seven-out' do

		Dice.any_instance.stub(:roll).and_return [3,4]

		round.point_roll(player)
		round.state.should == 'player_loss'
	end

end