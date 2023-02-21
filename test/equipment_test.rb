require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Equipment do
  it 'can have an attack value or not' do
    assert            Combat::Equipment.has_attack_value?(:long_sword)
    assert_equal  2,  Combat::Equipment.attack_value(:long_sword)

    assert            Combat::Equipment.has_attack_value?(:magic_sword)
    assert_equal  1,  Combat::Equipment.attack_value(:magic_sword)

    refute            Combat::Equipment.has_attack_value?(:leather_armor)
  end

  it 'can have an magic attack value or not' do
    refute            Combat::Equipment.has_magic_attack_value?(:long_sword)

    assert            Combat::Equipment.has_magic_attack_value?(:magic_sword)
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
    refute            Combat::Equipment.has_defense_value?(:long_sword)

    assert            Combat::Equipment.has_defense_value?(:leather_armor)
    assert_equal  2,  Combat::Equipment.defense_value(:leather_armor)

    assert            Combat::Equipment.has_defense_value?(:magic_helm)
    assert_equal  1,  Combat::Equipment.defense_value(:magic_helm)
  end

  it 'can have an magic defense value or not' do
    refute            Combat::Equipment.has_magic_defense_value?(:long_sword)

    assert            Combat::Equipment.has_magic_defense_value?(:magic_helm)
    assert_equal  1,  Combat::Equipment.magic_defense_value(:magic_helm)

    assert            Combat::Equipment.has_magic_defense_value?(:amulet)
    assert_equal  2,  Combat::Equipment.magic_defense_value(:amulet)
  end
end
