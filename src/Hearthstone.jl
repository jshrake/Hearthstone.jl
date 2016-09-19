"""
# Hearthstone

Functions to calculate the probabilities of different events in [Hearthstone: Heroes of Warcraft](http://us.battle.net/hearthstone/en/).

"""
module Hearthstone

export card_in_opening_hand_no_coin,
       card_in_opening_hand_coin,
       card_in_next_N_turns,
       missile_lethal
"""
    hypergeom_pmf(N::Integer, K::Integer, n::Integer, k::Integer)

Calculate the hypergeometric probability mass function.

# Arguments
* `N::Integer`: the population size.
* `K::Integer`: the number of success states in the population.
* `n::Integer`: the number of draws.
* `k::Integer`: the number of observed successes.
"""
function hypergeom_pmf(N::Integer, K::Integer, n::Integer, k::Integer)
  @assert(k >= max(0, n+K-N))
  @assert(k <= min(n, K))
  binomial(K, k) * binomial(N-K, n-k) / binomial(N, n)
end

"""
    hypergeom_cmf(N::Integer, K::Integer, n::Integer, ks::UnitRange{Integer})

Calculate the hypergeometric cumulative mass function.

# Arguments
* `N::Integer`: the population size.
* `K::Integer`: the number of success states in the population.
* `n::Integer`: the number of draws.
* `ks::UnitRange{Integer}`: the range of observed successes to accumulate over.
"""
function hypergeom_cmf{T<:Integer}(N::Integer, K::Integer, n::Integer, ks::UnitRange{T})
  f(a,b) = a + binomial(K, b) * binomial(N-K, n-b)
  num =  foldl(f, 0, ks)
  num / binomial(N,n)
end

"""
    card_in_opening_hand_coin(cardcount::Integer)

Returns the probability to obtain at least one card of cardcount total in the opening hand of the player with the coin.

# Arguments
* `cardcount::Integer`: the total number of cards of interest in the deck.
"""
function card_in_opening_hand_coin(cardcount::Integer)
  """
  Define events:
  A = Card not drawn in opening hand
  B = Card not drawn in initial 4 cards
  C = Card not drawn after replacing initial 4
  D = Card not drawn on first turn
  Then P(A) = P(B AND C AND D) = P(B) * P(C) * P(D)
  Calculate 1.0 - P(A)
  """
  not_in_initial = hypergeom_pmf(30, cardcount, 4, 0)
  not_in_replacement = hypergeom_pmf(26, cardcount, 4, 0)
  not_in_firstturn = hypergeom_pmf(26, cardcount, 1, 0)
  1.0 - (not_in_initial * not_in_replacement * not_in_firstturn)
end

"""
    card_in_opening_hand_no_coin(cardcount::Integer)

Returns the probability to obtain at least one card of cardcount total in the opening hand of the player without the coin.

# Arguments
* `cardcount::Integer`: the total number of cards of interest in the deck.
"""
function card_in_opening_hand_no_coin(cardcount::Integer)
  """
  Define events:
  A = Card not drawn in opening hand
  B = Card not drawn in initial 3 cards
  C = Card not drawn after replacing initial 3
  D = Card not drawn on first turn
  Then P(A) = P(B AND C AND D) = P(B) * P(C) * P(D)
  Calculate 1.0 - P(A)
  """
  not_in_initial = hypergeom_pmf(30, cardcount, 3, 0)
  not_in_replacement = hypergeom_pmf(27, cardcount, 3, 0)
  not_in_firstturn = hypergeom_pmf(27, cardcount, 1, 0)
  1.0 - (not_in_initial * not_in_replacement * not_in_firstturn)
end

"""
    card_in_next_N_turns(cardcount::Integer, deckcount::Integer, N::Integer)

Returns the probability to obtain at least one card of cardcount toal in the next N turns given
deckcount cards remaining in the deck.

# Arguments
* `cardcount::Integer`: the total number of cards of interest in the deck.
* `deckcount::Integer`: the total number of cards remaining in the deck.
* `N::Integer`: the number of turns.
"""
function card_in_next_N_turns(cardcount::Integer, deckcount::Integer, N::Integer)
  "1.0 - P(Do not draw desired card in N turns)"
  1.0 - hypergeom_pmf(deckcount, cardcount, N, 0)
end

"""
    missile_lethal(missilecount::Integer, enemyhealth::Integer, healthonboard::Integer)

Returns the probability to reduce the health of a character (minion or hero) with enemyhealth health to 0 health given missilecount missiles fired and healthonboard total health on the board, not including enemyhealth.

To account for friendly fire, such as playing Mad Bomber, include the health of your board and hero in healthonboard.

# Arguments
* `missilecount::Integer`: the total number of missiles to fire.
* `enemyhealth::Integer`: the total health of the character (minion or hero) to kill.
* `healthonboard::Integer`: the total health of all other characters on the board.
"""
function missile_lethal(missilecount::Integer, enemyhealth::Integer, healthonboard::Integer)
  hypergeom_pmf(enemyhealth + healthonboard, enemyhealth, missilecount, enemyhealth)
end

end # module
