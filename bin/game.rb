require 'pp'
require 'io/console'

require_relative '../lib/item.rb'
require_relative '../lib/monster.rb'
require_relative '../lib/player.rb'
require_relative '../lib/fight.rb'

READ_DELAY  = 1

ATMOSPHERE  = [ "You keep walking down the poorly lit corridor...",
                "The air is thick with a terrible smell of rotten flesh but"\
                " you keep moving on.",
                "You progress along a stone tunnel carved with images of"\
                " ungodly figures",
                "The passage gets narrower with each step but you manage to go"\
                "through and emerge in a vast opening.",
                "You walk in a great hall, amidst idols so gigantic you can't"\
                " make out their features",
                "In the distance, you can hear echoing screams of pain.",
                "You walk in what was once a lush garden, its trees now all"\
                " desiccated, its fruits all roten.",
                "You cross a rope bridge crossing over an abyss you can't see"\,
                " the bottom of.",
                "You slowly progress along what looks like a muddy mine tunnel.",
                "Your steps are regularly hampered by powerful tremors.",
                "You walk down a curving flight stairs roughly cut in the"\
                " mountain stone.",
                "You climb down a rope that seems to never end but eventually"\
                " reach solid ground."
                "As you walk a stone slab of the passageway collapses. You"\
                " fall one level lower. You feel a great pain in your ankle"\
                "but it doesn't seem to be broken or twisted.",
                "You walk a narrow footpath     lava",
                "You follow a narrow path carved in the side of a cliff.",
                "Knee-deep in icy cold water, you try to find the other exit "\
                "of a large hollow.",
                "You end up in front of a gigantic cascade. You can see a cave"\,
                " opening just behind it",
                "You carefully walk the winding path of a sleep crystal cave.",
                "You traverse what once was probably a majestic throne room.",
                "Several oddly shaped stones pave the floor of the room you "\
                "stand in.",
                "You stand at the transcept of the temple of a long forgotten "\,
                "god.",
                "The cave you are in is filled with a spectral fog." ]

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
