require 'pp'
require 'io/console'

require_relative '../lib/item.rb'
require_relative '../lib/monster.rb'
require_relative '../lib/player.rb'
require_relative '../lib/fight.rb'

READ_DELAY  = 0.5

ATMOSPHERE  = [ "You keep walking down the poorly lit corridor...",
                "The air is thick with a terrible smell of rotten flesh but you keep oving on.",
                "You progress along a stone tunnel carved with images of ungodly figures" ]

player  = Combat::Player.new  20,   # health
                              10,   # mana
                               5,   # strength
                               3,   # intelligence
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

    sleep READ_DELAY
  end
end
