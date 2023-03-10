require 'minitest/pride'

#require_relative  '../lib/monster.rb'
require_relative  './equipment_for_tests.rb'
require_relative  '../lib/equipment.rb'
require_relative  './items_for_tests.rb'
require_relative  '../lib/item.rb'
require_relative  './spells_for_tests.rb'
require_relative  '../lib/spell.rb'
require_relative  '../lib/message.rb'
require_relative  '../lib/actor.rb'
require_relative  '../lib/fight.rb'
#require_relative  '../lib/player.rb'

def same_effect?(effect1,effect2)
  effect1[:source]      == effect2[:source]     &&
  effect1[:neffectme]   == effect2[:neffectme]  &&
  effect1[:on]          == effect2[:on]         &&
  effect1[:turns]       == effect2[:turns]
end
