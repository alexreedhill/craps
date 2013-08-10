require 'game'
require 'dice'

describe Game do
	let(:game) { Game.new }

	it "should capture first roll between 2 and 12" do
	  game.make_first_roll
	  game.first_roll_result.should be >= 2
	  game.first_roll_result.should be <= 12
	end

	it 'adds the return values for dice roll' do 
		
		Dice.any_instance.stub(:roll).and_return [5,6]

		game.make_first_roll
		game.first_roll_result.should == 11
	end

end