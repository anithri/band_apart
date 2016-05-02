require 'squib'

data = Squib.csv file: 'primary_cards.csv'
Squib::Deck.new cards: data['title'].size, layout: 'primary_card_layout.yml' do
  background color: data['background_color']
  rect layout: 'cut' # cut line as defined by TheGameCrafter
  rect layout: 'safe' # safe zone as defined by TheGameCrafter
  rect layout: 'power_frame'
  text layout: 'title', str: data['title']
  text layout: 'power', str: data['power']
  svg layout: 'icon_one', file: data['icon_one']
  svg layout: 'icon_two', file: data['icon_two']
  svg layout: 'icon_three', file: data['icon_three']
  svg layout: 'icon_four', file: data['icon_four']
  svg layout: 'art', file: data['picture']
  text layout: 'type', str: data['flavor']
  circle layout: 'fortune_frame'
  text layout: 'fortune', str: data['fortune']
  text layout: 'lower_left', str: data['tier']
  save_png
  save_pdf file: 'cards.pdf'
end
