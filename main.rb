require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

  Card = Struct.new(:suit, :value , :show_value)
  Human = Struct.new(:name, :cards, :total_value , :dealer_or_not)

helpers do

  module Deck

    def initialize_deck how_many_decks
      deck = []
      suits_array = ['♠','♥','♣','♦']
      how_many_decks.times do
        suits_array.each do |suit|
          counter = 1
          while counter <=13
            card = Card.new( suit, (counter >= 10 ? 10 : counter) , Deck.convention_show_value(counter) )
            counter += 1
            deck.push card
          end
        end
      end
      deck.shuffle!
    end

    def convention_show_value value
      case value
      when  1
        'A'
      when  11
        'J'
      when  12
        'Q'
      when  13
        'K'
      when 2..10 
        value    
      end
    end

  end

  module People

    def restart who
      who[:cards] = []
      who[:total_value] = 0
    end


    def status who
      if who[:total_value] > 21
        'busted'
      elsif who[:total_value] < 21
        'safe'
      elsif who[:total_value] == 21
        'BlackJack'
      else
        puts 'ERROR!! HERE'
      end
    end

    def push (card, who)
      who[:cards].push(card)
      who[:total_value] += card[:value]
      who[:cards].select { |card| card[:show_value] == 'A' }.count.times do
        who[:total_value] +=10 if ( who[:total_value] + 10 ) <= 21
      end
    end

    def puts_cards who
      role = ( who[:dealer_or_not] ? 'dealer' : 'player' )
      puts"#{role} #{@name} has cards"
      who[:cards].each {|card| card.puts_card }
      puts"total value = #{@total_value}"
      puts ''
    end


  end

  module HTMLOut

    def cards_img card

      suit = ''
      show_value = ''

      suit = 
        case card[:suit]
        when '♠' then 'spades'
        when '♥' then 'hearts'
        when '♣' then 'clubs'
        when '♦' then 'diamonds'
        end

      show_value = 
        case card[:show_value]
        when 'A' then 'ace'
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        else card[:show_value].to_s
        end

      "<img src='/images/cards/#{suit}_#{show_value}.jpg' class='card_image'>"

    end
  

    def card_cover
      "<img src='/images/cards/cover.jpg' class='card_image'>"
    end

end

end


include Deck
include People
include HTMLOut

get '/' do

  erb:name

end

post '/entername' do
  session[:playername] = params[:playername]
  redirect 'presetgame'
end

get '/presetgame' do
  session[:dollars] = 500
  session[:decks] = Deck.initialize_deck(1)
  session[:player] = Human.new(session[:playername],[],0,false)
  session[:dealer] = Human.new('dealer',[],0,true)

  redirect '/bet'

end

get '/bet' do
  erb:bet
end

post '/bet' do
  session[:bet] = params[:bet]
  redirect '/startgame'
end

get '/startgame' do
  People.restart(session[:player])
  People.restart(session[:dealer])
  2.times do
    People.push(session[:decks].pop,session[:player])
    People.push(session[:decks].pop,session[:dealer])
  end
  redirect '/game'
end

get '/game' do
  session[:show_first_card] = false
  erb:game
end