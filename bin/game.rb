require 'pp'
require 'io/console'

require_relative '../lib/item.rb'
require_relative '../lib/monster.rb'
require_relative '../lib/player.rb'
require_relative '../lib/fight.rb'

#START_MESSAGE = [ "A #

player  = Combat::Player.new  20,   # health
                              10,   # mana
                               5,   # strength
                               3,   # intelligence
                               2,   # defense 
                               0,   # magic_defense
                              #[]    # starting items
                              [:long_sword, :health_potion, :fire_wand]    # starting items

puts  'You enter the Labyrinth of Death! Beware the foul monsters roaming '\
      'its deadly corridors...'

while true do
  monster = Combat::Monster.new_random_monster
  puts "A #{monster.name} lurks out from the dark!!!"

  fight = Combat::Fight.new player, monster
  while fight.is_on do
    step = fight.run

    puts step[:message] if step[:should_print]

    if fight.player.dead?
      puts 'You died...'
      exit(0)
    end

    if fight.monster.dead?
      puts "You defeated the #{monster.name}! You can move on!"
      break
    end
  end
end
