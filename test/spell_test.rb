require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Spell do
  before do
    @f   = Combat::Spell.new_fire_ball
    @h   = Combat::Spell.new_heal
    @rd  = Combat::Spell.new_raise_defense
    @rmd = Combat::Spell.new_raise_magic_defense
    @ra  = Combat::Spell.new_raise_attack
    @rma = Combat::Spell.new_raise_magic_attack

    @templates = Combat::Spell::SPELLS
  end

  it 'creates spells' do
    assert_equal  :fire_ball, @f.type
    assert_equal  0,          @f.turns_left

    assert_equal  :raise_defense, @rd.type
    assert_equal  3,              @rd.turns_left 
  end

  it 'knows its name' do
    assert_equal "War Cry", @ra.name
  end

  it 'can be a defense buff' do
    assert            @rd.defense_spell?
    assert_equal  2,  @rd.defense
  end

  it 'can be a magic defense buff' do
    assert            @rmd.magic_defense_spell?
    assert_equal  2,  @rmd.magic_defense
  end

  it 'can be a attack buff' do
    assert            @ra.attack_spell?
    assert_equal  2,  @ra.attack
  end

  it 'can be a magic attack buff' do
    assert            @rma.magic_attack_spell?
    assert_equal  2,  @rma.magic_attack
  end

  it 'can wear out' do
    assert_equal  3, @ra.turns_left
    @ra.fade
    assert_equal  2, @ra.turns_left
    @ra.fade
    assert_equal  1, @ra.turns_left
    @ra.fade
    assert           @ra.faded?
    assert           @ra.done?
  end
end

