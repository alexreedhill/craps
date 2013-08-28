require 'player'
require 'round'
require 'dice'

describe Player do
	let(:player) { Player.new }
	let(:round) { Round.new }

	it 'places pass line bet' do
		
		player.make_pass_bet(5)
		player.chip_count.should == 95
		
	end

	it 'places pending come bet' do

			round.point = 6
			player.make_come_bet(5)
			player.pending_come_bet.should == 5

	end

	it 'places come bet after roll' do

		player.pending_come_bet = 5
		roll_result = 8
		player.come_bets = round.place_come_bet(player, roll_result)
		player.come_bets.should == [{:amount =>5,:point =>8}]

	end

	it 'places odds on pass line bet' do

		player.pass_bet = 5
		player.place_pass_odds
		player.pass_odds.should == 10
	end

	it 'places odds on come bet' do
		player.come_bets = [{:amount => 5, :point => 6}, {:amount => 10, :point => 9}]
		player.place_come_odds(player.come_bets[0])
		player.place_come_odds(player.come_bets[1])
		player.come_bets.should == [{:amount => 5, :point => 6, :odds => 10}, {:amount => 10, :point => 9, :odds => 20}]
	end

	it 'throws out pending come bet on seven out' do 
		player.pass_bet = 5
		player.make_come_bet(5)
		
	end

end