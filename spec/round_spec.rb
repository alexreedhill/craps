require 'round'
require 'dice'
require 'player'

describe Round do
	let(:player) { Player.new }
	let(:round) { Round.new }

	it 'pays correct amount on natural' do
		player.make_pass_bet(5)
		player.chip_count += round.pass_line_payout(player, 5)
		player.chip_count.should == 105

	end

	it 'pays correct amount on come bet' do

		player.come_bets = [{:amount => 5, :point => 8}]
		player.chip_count = 95
		update_player = round.come_bet_payout(player, 8, 'point')
		player = update_player
		player.chip_count.should == 106

	end

	it 'pays correct amount on pass' do 
		player.pass_bet = 10
		player.chip_count = 90
		player.chip_count += round.pass_win_payout(player, 6)
		player.chip_count.should == 110
	end

	it 'pays correct odds on 5,9 point bets' do
			player.pass_bet = 5
			player.come_bets = [{:amount => 5, :point => 5}]
			player.chip_count = 90
			update_player = round.come_bet_payout(player, 5, 'point')
			player = update_player
			player.chip_count += round.pass_win_payout(player, 5)
			player.chip_count.should == 112.5
	end

	it 'pays correct odds on 4, 10 point bets' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 5, :point => 4}]
		player.chip_count = 90
		update_player = round.come_bet_payout(player, 4, 'point')
		player = update_player
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
		update_player = round.come_bet_payout(player, 6, 'point')
		player = update_player
		player.chip_count.should == 136
	end

	it 'carries over multiple come bets with odds on pass' do
		player.pass_bet = 5
		player.come_bets = [{:amount => 10, :point => 9, :odds => 20}, {:amount => 5, :point => 4, :odds => 10}]
		player.chip_count = 50
		player.chip_count += round.pass_win_payout(player, 6)
		round = Round.new 
		round.comeout_roll(player)
		player.come_bets.should == [{:amount => 10, :point => 9, :odds => 20}, {:amount => 5, :point => 4, :odds => 10}]
	end
	
	it 'pays come bet but withdraws odds if hit on comeout roll' do
		player.come_bets = [{:amount => 5, :point => 4, :odds => 10}]
		player.chip_count = 85
		update_player = round.come_bet_payout(player, 4, 'comeout')
		player.chip_count.should == 110
	end

	it 'pays pending come bet on seven-out' do
		player.pending_come_bet = 5
		player.chip_count = 95
		player.chip_count += round.pending_come_bet_payout(player)
		player.chip_count.should == 105
	end

end