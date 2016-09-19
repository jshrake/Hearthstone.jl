using Hearthstone
using Base.Test

@test_approx_eq_eps Hearthstone.card_in_opening_hand_coin(2) 0.5098 1e-4
@test_approx_eq_eps Hearthstone.card_in_opening_hand_no_coin(2) 0.4125 1e-4
@test_approx_eq Hearthstone.card_in_next_N_turns(1, 20, 1) 1/20
@test Hearthstone.missile_lethal(10, 8, 2) == 1.0
