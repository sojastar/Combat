require 'pp'
require 'io/console'

require_relative '../lib/item.rb'
require_relative '../lib/monster.rb'
require_relative '../lib/player.rb'
require_relative '../lib/fight.rb'

READ_DELAY  = 1

ATMOSPHERE  = [ "You keep walking down the poorly lit corridor...",
                "The air is thick with a terrible smell of rotten flesh but you keep oving on.",
                "You progress along a stone tunnel carved with images of ungodly figures",
                "The passage gets narrower with each step but you manage to go through "\
                "and emerge in a vast opening.",
                "You walk in a great hall, amidst idols so gigantic you can't make out their features",
                "In the distance, you can hear echoing screams of pain.",
                "You walk in what was once a lush garden, its trees now all desiccated, its fruits all roten." ]

player  = Combat::Player.new  20,   # health
                              10,   # mana
                               5,   # strength
                               3,   # intelligence
                              #[]    # starting items
                              [:long_sword, :health_potion, :fire_wand]    # starting items

puts  'You enter the Labyrinth of Death! Beware the foul monsters roaming '\
      'its deadly corridors...'
sleep READ_DELAY

while true do
  puts ATMOSPHERE.sample
  sleep READ_DELAY

  monster = Combat::Monster.new_random_monster
  puts "A #{monster.name} lurks out from the dark!!!"
  sleep READ_DELAY

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
