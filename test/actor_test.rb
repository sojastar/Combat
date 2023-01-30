require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Actor do
  before do
    @actor  = Combat::Actor.new(  { type:         :player,
                                    name:         'The GUY!' ,
                                    strength:      3,
                                    intelligence:  2,
                                    health:       10,
                                    mana:          5,
                                    equipment:    [:long_sword, :leather_armor],
                                    items:        [:health_potion],
                                    spells:       Combat::Spell::SPELLS } )
  end

  it 'initialises properly' do
    assert_equal  :player,    @actor.type 
    assert_equal  'The GUY!', @actor.name
    assert_equal  3,          @actor.strength
    assert_equal  2,          @actor.intelligence
    assert_equal  10,         @actor.health
    assert_equal  5,          @actor.mana

    assert_equal  1,  @actor.items.length
    assert            @actor.items.any? { |item| item.type == :health_potion }

    assert_equal  2,  @actor.equipment.length
    assert            @actor.equipment.any? { |item| item.type == :long_sword }
    assert            @actor.equipment.any? { |item| item.type == :leather_armor }

    assert_equal  Combat::Spell::SPELLS,  @actor.spells
    assert_empty                          @actor.active_spells
  end

  it 'has initiative' do
    assert_equal 5, @actor.initiative
  end

  it 'knows if it is alive' do
    assert @actor.alive?
  end

  #it 'knows if it is dead' do
  #  @p.hit( { type: :physical_attack, damage: 25 } )

  #  assert @p.dead?
  #end
end
