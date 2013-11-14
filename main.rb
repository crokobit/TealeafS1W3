require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do

############################# BJ OOP START
  class Card

    attr_accessor :suit, :show_value, :value

    def initialize(suit,value)
      @suit = suit
      @show_value = convention_show_value(value)
      @value = value
    end

    def puts_card
      puts"#{suit} #{show_value}"
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

  class Deck

    attr_accessor :deck

    def initialize how_many_decks
      @deck = []
      suits_array = ['♠','♥','♣','♦']
      how_many_decks.times do
        suits_array.each do |suit|
          counter = 1
          while counter <=13
            card = Card.new( suit, counter )
            counter += 1
            deck.push card
          end
        end
      end
    end

    def puts_deck
      deck.each do |card|
        card.puts_card 
      end
    end

    def shuffle
      @deck.shuffle!
    end

    def pop
      @deck.pop
    end

    def push card
      @deck.push(card)
    end

  end


  class People

    attr_accessor :name, :cards, :total_value, :dealer

    def initialize ( name , dealer_or_not )
      @name = name
      @cards = []
      @total_value = 0
      @dealer = dealer_or_not
    end

    def restart
      @cards = []
      @total_value = 0
    end

    def is_dealer
      @dealer = true
    end

    def status
      if @total_value > 21
        'busted'
      elsif @total_value < 21
        'safe'
      elsif @total_value == 21
        'BlackJack'
      else
        puts 'ERROR!! HERE'
      end
    end

    def push card
      @cards.push(card)
      @total_value += card.value
      total_value_consider_A
    end

    def total_value_consider_A
      cards.select { |card| card.show_value == 'A' }.count.times do
        total_value +=10 if ( total_value + 10 ) <= 21
      end
    end

    def puts_cards
      role = ( @dealer ? 'dealer' : 'player' )
      puts"#{role} #{@name} has cards"
      @cards.each {|card| card.puts_card }
      puts"total value = #{@total_value}"
      puts ''
    end

    def clean_card
      @cards = []
    end

    def clean_total_value
      @total_value = 0
    end

  end

  class Game
    def initialize_command_line_mode
      puts "Game start"
      puts "Set Player"
      puts "Enter dealer's name"
      name = gets.chomp
      @dealer = People.new(name,true)
      puts "Enter Player's name"
      name = gets.chomp
      puts ''
      @player = People.new(name,false)
      @deck = Deck.new(4) #use 4 decks
      @deck.shuffle
    end

    def initialize(playername)
      puts "Game start"
      puts "Set Player"
      puts "Enter dealer's name"
      @dealer = People.new('',true)
      puts "Enter Player's name"
      puts ''
      @player = People.new(playername,false)
      @deck = Deck.new(4) #use 4 decks
      @deck.shuffle
    end

    def start_game
      2.times do
        @dealer.push(@deck.pop)
        @player.push(@deck.pop)
      end
    end

    def restart_game
      @dealer.restart
      @player.restart
    end

    def status
      #puts"dealer status"
      @dealer.puts_cards
      #puts"player status"
      @player.puts_cards
    end

    def hit_or_stay (who,action)


      if who == 'dealer'
        block = @dealer
      elsif who == 'player'
        block = @player
      else
        puts "ERROR!!!!"
      end


      puts"#{block.name} #{who} do you want to hit or to stay"
      flow = action
      puts ''
      if flow == 'hit'
        puts"#{block.name} #{who} hit a card"
  #      binding.pry
        block.push(@deck.pop)
      elsif flow == 'stay' && who == 'dealer' && @dealer.total_value < 17
        puts"#{block.name} #{who} , your total value < 17, you must hit a card" 
        flow = 'hit'
        block.push(@deck.pop)      
      elsif flow == 'stay'
        puts"#{block.name} #{who} stay"
      else
        puts "ERROR"
      end
      puts ''
      flow

    end


    def one_of_people_BJ_or_busted
      not ( ( @dealer.status  == 'safe' ) && ( @player.status == 'safe') )
    end

    def end_game
      if one_of_people_BJ_or_busted
        if ( ( @dealer.status == 'BlackJack' ) || (@player.status == 'busted'))
          puts 'dealer win!!'
          true
        elsif ( ( @player.status == 'BlackJack' ) || (@dealer.status == 'busted'))
          puts 'player win!!'
          true
        elsif ( @dealer.total_value == @player.total_value )
          puts "draw ~~~!!!"
          true
        else
          puts 'ERROR'
        end
      end
    end

    def end_game_compare
      if @dealer.total_value > @player.total_value
        puts 'dealer win'
      elsif @dealer.total_value < @player.total_value
        puts 'player win'
      else
        puts 'draw!!!~~'
      end
    end

    def end_deal_cards
      @dealer.clean_card
      @dealer.clean_total_value
      @player.clean_card
      @player.clean_total_value
      @deck.shuffle
    end

  end



end

#########BJ GAME OOP END

get '/' do

  erb:name

end

post '/entername' do
  session[:game] = Game.new(params[:palyername])
  session[:name] = params[:palyername]
  session[:dollars] = 500
  redirect '/presetgame'

end

get '/presetgame' do
  session[:game] = Game.new( session[:name] )
  session[:game].start_game
  session[:play_or_not] = true
  redirect '/bet'
end

get '/bet' do
  erb:bet
end

post '/bet' do
  session[:bet] = params[:bet]
  session[:who] = 'player'
  session[:do_what] = 'stay'

  redirect '/game'


end

get '/game' do

    player_array = ['player','dealer']
    game = session[:game]
    #session[:game] disappear
    who = session[:who]
    do_what = session[:do_what]
    while ( ( do_what != 'stay' ) && ( game.one_of_people_BJ_or_busted != true ) )
      game.status
    end

    if ( ( who == 'dealer' ) && ( do_what == 'stay' ) )
      game.end_game_compare
    end

    if ( game.end_game == true && who == 'dealer' ) #dealer last
      break
    end

  erb :game
end


#press hit or stay to here
post '/turn' do 


end

