# -*- coding: utf-8 -*-
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
      People.calculate_value(who)

    end

    def calculate_value who
      who[:total_value] = 0
      who[:cards].each {|card| who[:total_value] += card[:value]}
      who[:cards].each do |card|
      who[:cards].select { |card| card[:show_value] == 'A' }.count.times do       
        who[:total_value] += 10 if ( who[:total_value] + 10 ) <= 21
      end

      end
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

module Game






end

include Deck
include People
include HTMLOut
include Game

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
  session[:dealer] = Human.new('',[],0,true)

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
  session[:show_first_card] = false
  session[:conclusion_or_not] = false
  session[:dealer_turn_or_not] = false
  session[:conclusion] = ''
  redirect '/game'
end

get '/game' do

  if !(People.status(session[:player]) == 'safe')
    redirect '/game/conclusion'
  end

  erb:game

end

post '/game/hit' do

  People.push(session[:decks].pop,session[:player])
  case People.status(session[:player])
  when 'busted'     then redirect '/game/conclusion'
  when 'BlackJack'  then redirect '/game/conclusion'
  when 'safe'       then redirect '/game'
  end


end

post '/game/stay' do

  session[:dealer_turn_or_not] = true
  erb:game

end


post '/game/dealer' do

  People.push(session[:decks].pop,session[:dealer])  

  if( session[:dealer][:total_value] < 17 )
    erb:game
  else
    redirect '/game/conclusion'
  end


end

get '/game/conclusion' do
  session[:dealer_turn_or_not] = true
  session[:conclusion_or_not] = true
  session[:show_first_card] = true

  ps = People.status(session[:player])
  ds = People.status(session[:dealer])

  if ps == 'busted'
    session[:conclusion] = "dealer"
  elsif ds == 'busted'
    session[:conclusion] = "player"
  elsif ps == 'safe' && ds == 'safe'

    if session[:dealer][:total_value] > session[:player][:total_value]
      session[:conclusion] = "dealer"
    elsif session[:dealer][:total_value] < session[:player][:total_value]
      session[:conclusion] = "player"
    else
      session[:conclusion] = 'draw'
    end

  elsif ps == ds
    session[:conclusion] = "draw"
  elsif ps == 'BlackJack'
    session[:conclusion] = "player"
  elsif ds == 'BlackJack'
    session[:conclusion] = "dealer"
  end


  case session[:conclusion]
  when 'draw' then
  when 'dealer' then session[:dollars] -= session[:bet].to_i
  when 'player' then session[:dollars] += session[:bet].to_i
  end

  erb:game

end

















