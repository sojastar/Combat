require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Spell do
  #before do
  #  @fire_ball            = Combat::Spell.new_fire_ball
  #  @heal                 = Combat::Spell.new_heal
  #  @raise_defense        = Combat::Spell.new_raise_defense
  #  @raise_magic_defense  = Combat::Spell.new_raise_magic_defense
  #  @raise_attack         = Combat::Spell.new_raise_attack
  #  @raise_magic_attack   = Combat::Spell.new_raise_magic_attack

  #  @templates = Combat::Spell::SPELLS
  #end

  it 'can return the name of a spell' do
    assert_equal  'Fire Ball', Combat::Spell.name(:fire_ball)
  end

  it 'can return the cost of a spell' do
    assert_equal  3, Combat::Spell.cost(:fire_ball)
  end

  it 'requires a certain intelligence level to be cast' do
    stupid  = 3
    average = 4
    smart   = 5

    refute  Combat::Spell.can_cast?(stupid,   :fire_ball)
    assert  Combat::Spell.can_cast?(average,  :fire_ball)
    assert  Combat::Spell.can_cast?(smart,    :fire_ball)
  end

  it 'can return the effects of a spell' do
    assert_equal  Combat::Spell::SPELLS[:fire_ball][:effects],
                  Combat::Spell.effects(:fire_ball)
  end
  #it 'creates spells' do
  #  assert_equal  :fire_ball, @f.type
  #  assert_equal  0,          @f.turns_left

  #  assert_equal  :raise_defense, @rd.type
  #  assert_equal  3,              @rd.turns_left 
  #end

  #it 'knows its name' do
  #  assert_equal "War Cry", @ra.name
  #end

  #it 'knows its intelligence requirement value' do
  #  assert_equal  4, @f.required_intelligence
  #end

  #it 'can be a defense buff' do
  #  assert            @rd.defense_spell?
  #  assert_equal  2,  @rd.defense
  #end

  #it 'can be a magic defense buff' do
  #  assert            @rmd.magic_defense_spell?
  #  assert_equal  2,  @rmd.magic_defense
  #end

  #it 'can be a attack buff' do
  #  assert            @ra.attack_spell?
  #  assert_equal  2,  @ra.attack
  #end

  #it 'can be a magic attack buff' do
  #  assert            @rma.magic_attack_spell?
  #  assert_equal  2,  @rma.magic_attack
  #end

  #it 'can wear out' do
  #  assert_equal  3, @ra.turns_left
  #  @ra.fade
  #  assert_equal  2, @ra.turns_left
  #  @ra.fade
  #  assert_equal  1, @ra.turns_left
  #  @ra.fade
  #  assert           @ra.faded?
  #  assert           @ra.done?
  #end
end

