require 'squib'

Squib::Deck.new cards: 6, layout: 'economy.yml' do
  background color: 'white'
  rect layout: 'cut' # die cut line as defined by TheGameCrafter
  rect layout: 'safe' # safe zone as defined by TheGameCrafter
  text str: ['Bruce', 'Tim', 'Barbara', 'Alfred', 'James', 'Selina'].shuffle,
       layout: 'title'
  text str: "Draw #{rand(1..5)} cards.", layout: 'description'
  save_png
end
