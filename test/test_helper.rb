require 'minitest/pride'

#require_relative  '../lib/monster.rb'
require_relative  '../lib/equipment.rb'
require_relative  './equipment_for_tests.rb'
require_relative  '../lib/item.rb'
require_relative  './items_for_tests.rb'
require_relative  '../lib/spell.rb'
require_relative  './spells_for_tests.rb'
require_relative  '../lib/message.rb'
require_relative  '../lib/actor.rb'
require_relative  '../lib/fight.rb'
#require_relative  '../lib/player.rb'

def same_effect(a1,a2)
  a1[:source] == a2[:source]  &&
  a1[:on]     == a2[:on]      &&
  a1[:turns]  == a2[:turns]
end
