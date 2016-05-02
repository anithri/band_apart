#!/usr/bin/env ruby
require 'ffaker'
require 'csv'
CARD_TYPES      = ['fame', 'music', 'style']
CARDS_PER_SHEET = 18 # GameCrafter

AVATARS = %w{nun policeman manager showman cashier judge
builder farmer taxi-driver croupier astronaut maid
croupier waiter captain firefighter engineer
sheriff loader motorcyclist concierge doctor writer
assistant soldier gentleman thief cooker surgeon
doctor stewardess detective miner businessman pilot nurse
courier journalist teacher welder diver swat soldier priest
postman scientist dj}.map { |n| "avatars/#{n}.svg" }

BACKGROUND_COLORS = {
  'special' => 'beige',
  'fame'    => 'light_yellow',
  'music'   => 'azure',
  'style'   => 'amethyst',
}

TYPE_COMBOS = CARD_TYPES.permutation(3).to_a.map { |a| a.take(2) }

TIER_STRENGTHS = [
  [[1, 0], [1, 0], [1, 0], [1, 0], [2, 0], [2, 0], [2, 0]],
  [[2, 0], [1, 1], [2, 0], [3, 0], [3, 0]],
  [[3, 0], [2, 1], [1, 2]],
  [[4, 0], [2, 2], [2, 2]]
]

POWER_DEFINITIONS = {
  draw_card:     'Draw ? Card(s).',
  replay:        'Use a power of the card on top of the discard pile',
  claim_card:    'Claim a card of same color from the top of the discard pile',
  hand_in_till:  'You gain 10% of the bands money at the end of the tour.',
  synergy:       'You may pay to recruit any one card as they if were any type',
  cash_in:       'You may recruit a card and immediately bank it.',
  endorsement:   'Bank this card after recruiting with it.',
  steal_thunder: 'Claim a card of the same color from another members bank.',
  headline:      'Score Two victory points.',

}

# 4, 5, 4, 4, 2

tier_1_powers = [:draw_card, :replay, :claim_card, :hand_in_till] * 2
tier_2_powers = [:draw_card, :replay, :claim_card, :hand_in_till, :cash_in] * 2
tier_3_powers = [:cash_in, :synergy, :synergy, :endorsement] * 2
tier_4_powers = [:endorsement, :steal_thunder, :headline] * 2
tier_5_powers = [:headline, :steal_thunder] * 2

POWERS = Hash.new do |h, k|
  h[k] = [
    tier_1_powers.shuffle.map { |p| POWER_DEFINITIONS[p] },
    tier_2_powers.shuffle.map { |p| POWER_DEFINITIONS[p] },
    tier_3_powers.shuffle.map { |p| POWER_DEFINITIONS[p] },
    tier_4_powers.shuffle.map { |p| POWER_DEFINITIONS[p] },
    tier_5_powers.shuffle.map { |p| POWER_DEFINITIONS[p] },
  ]
end

def recruit_msg(type)
  %{You may recruit anyone for normal price.  You gain +2 money for #{type}
recruits.  You may spend 2 extra to recruit into your hand instead of the
discard pile.}.gsub(/\n/,' ')
end

def power_msg(power_lvl, type)
  [POWERS[type][power_lvl - 1].pop + recruit_msg(type)].join(' ')
end

SHEETS_PER_TYPE     = 2
EXPECTED_CARD_TOTAL = CARDS_PER_SHEET * SHEETS_PER_TYPE * (CARD_TYPES.length + 1)

def generate_card_data
  out = []
  TYPE_COMBOS.each do |primary, secondary|

    TIER_STRENGTHS.each_with_index do |strengths, tier|
      strengths.each do |pri_str, sec_str|
        out << gen_card(tier, primary, pri_str, secondary, sec_str)
      end
    end

  end
  out
end

def gen_card(tier, pri, pri_str, sec, sec_str)
  power_str = sec_str.zero? ? pri_str : (pri_str + sec_str + 1)
  icons     = Array.new(pri_str) { pri } + Array.new(sec_str) { sec }
  icons.map! { |i| "#{i}.svg" }
  {
    title:            FFaker::Job.title,
    picture:          AVATARS.sample,
    background_color: BACKGROUND_COLORS[pri],
    flavor:           flavor_text,
    tier:             tier.zero? ? 'Start' : "Tour #{tier}",
    fortune:          power_str,
    power:            power_msg(power_str, pri),
    icon_one:         icons[0],
    icon_two:         icons[1],
    icon_three:       icons[2],
    icon_four:        icons[3]
  }
end

FLAVOR_TYPES=[:album, :artist, :genre, :song]

def flavor_text
  flavor_type = FLAVOR_TYPES.sample
  flavor      = FFaker::Music.send(flavor_type)
  "Favorite #{flavor_type}: #{flavor}"
end

def fortune_for(tier, pri_val, sec_val)
  tier + pri_val * 2 + sec_val * 3
end

deck = generate_card_data

# Before Save
# Assume 1 sheet of 18 per pri/sec combo + 2 specials
if deck.length != 6 * 18
  abort("Invalid Card Count: #{deck.length} of 108 expected")
end

CSV.open('primary_cards.csv', "wb") do |csv|
  csv << deck.first.keys.map(&:to_s)
  deck.each { |card| csv << card.values }
end
