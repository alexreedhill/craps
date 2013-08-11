require 'player'
require 'round'
require 'dice'

describe Player do
	let(:player) { Player.new }
	let(:round) { Round.new }

	it 'subtracts bet from player chips' do
		
		player.make_line_bet('pass', 5)
		player.chip_count.should == 95
		
	end

	it 'recieves correct amount on natural' do
		
		player.make_line_bet('pass', 5)
		round.state = 'player_win_natural'
		player.chip_count = round.pass_bet_payout(player.chip_count, 5)
		player.chip_count.should == 105

	end

	it 'places pending come bet' do
			round.point = 6
			player.make_come_bet(5)
			player.pending_come_bet_amount.should == 5
	end

	it 'places come bet after roll' do
		player.pending_come_bet_amount = 5
		roll_result = 8
		player.come_bets = round.place_come_bet(player, roll_result)
		player.come_bets.should == [{:amount =>5,:point =>8}]
	end

	it 'recieves correct amount on come bet' do
		player.come_bets = [{:amount => 5, :point => 8}]
		player.chip_count = round.come_bet_payout(player, 8)
		player.chip_count.should == 106
	end

	xit 'recieves payouts on multiple come bets' do 

	end

end