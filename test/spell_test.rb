require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Spell do
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
end
