Card = Struct.new(:suit, :value , :show_value)
Human = Struct.new(:name, :cards, :total_value , :dealer_or_not)
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


module Game 

  def start_game (player, dealer, decks)
    restart_game(player)
    restart_game(dealer)
    player.push(@deck.pop)
    dealer.push(@deck.pop)
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

  def hit_or_stay who


    if who == 'dealer'
      block = @dealer
    elsif who == 'player'
      block = @player
    else
      puts "ERROR!!!!"
    end


    puts"#{block.name} #{who} do you want to hit or to stay"
    flow = gets.chomp
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

include Deck
include People


deck = Deck.initialize_deck(1)
player = Human.new('crokobit',[],0,false)
puts deck.pop
People.push(deck.pop,player)
People.push(deck.pop,player)
People.restart(player)
puts player
#  module_function :hello
