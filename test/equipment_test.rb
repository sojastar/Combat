require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Equipment do
  it 'can return the name of a piece of equipment' do
    assert_equal  'Long Sword', Combat::Equipment.name(:long_sword)
  end

  it 'can have an attack value or not' do
    assert            Combat::Equipment.raise_attack?(:long_sword)
    assert_equal  2,  Combat::Equipment.attack_value(:long_sword)

    assert            Combat::Equipment.raise_attack?(:magic_sword)
    assert_equal  1,  Combat::Equipment.attack_value(:magic_sword)

    refute            Combat::Equipment.raise_attack?(:leather_armor)
  end

  it 'can have an magic attack value or not' do
    refute            Combat::Equipment.raise_magic_attack?(:long_sword)

    assert            Combat::Equipment.raise_magic_attack?(:magic_sword)
    assert_equal  1,  Combat::Equipment.magic_attack_value(:magic_sword)
  end

  it 'can have ailment effects or not' do
    refute            Combat::Equipment.has_ailment_effect?(:long_sword)

    assert            Combat::Equipment.has_ailment_effect?(:poisoned_dagger)
    assert_equal   1, Combat::Equipment.ailment_effects(:poisoned_dagger).length
    assert_equal   [ Combat::Equipment::PIECES[:poisoned_dagger][:effects].last ],
                      Combat::Equipment.ailment_effects(:poisoned_dagger)
  end

  it 'can have an defense value or not' do
    refute            Combat::Equipment.raise_defense?(:long_sword)

    assert            Combat::Equipment.raise_defense?(:leather_armor)
    assert_equal  2,  Combat::Equipment.defense_value(:leather_armor)

    assert            Combat::Equipment.raise_defense?(:magic_helm)
    assert_equal  1,  Combat::Equipment.defense_value(:magic_helm)
  end

  it 'can have an magic defense value or not' do
    refute            Combat::Equipment.raise_magic_defense?(:long_sword)

    assert            Combat::Equipment.raise_magic_defense?(:magic_helm)
    assert_equal  1,  Combat::Equipment.magic_defense_value(:magic_helm)

    assert            Combat::Equipment.raise_magic_defense?(:amulet)
    assert_equal  2,  Combat::Equipment.magic_defense_value(:amulet)
  end
end
