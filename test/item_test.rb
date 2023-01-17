require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Item do
  it 'creates items' do
    s = Combat::Item.new_long_sword
    l = Combat::Item.new_leather_armor
    a = Combat::Item.new_amulet
    h = Combat::Item.new_health_potion
    m = Combat::Item.new_mana_potion
    w = Combat::Item.new_fire_wand

    item_templates  = Combat::Item::ITEMS

    assert_equal  :long_sword,    s.type
    refute                        s.usable

    assert_equal  :leather_armor, l.type
    refute                        l.usable

    assert_equal  :amulet,        a.type
    refute                        a.usable

    assert_equal  :health_potion,                 h.type
    assert                                        h.usable
    assert_equal  item_templates[h.type][:uses],  h.uses

    assert_equal  :mana_potion,                   m.type
    assert                                        h.usable
    assert_equal  item_templates[m.type][:uses],  m.uses
    
    assert_equal  :fire_wand,                     w.type
    assert                                        h.usable
    assert_equal  item_templates[w.type][:uses],  w.uses
  end

  it 'is used' do
    w = Combat::Item.new_fire_wand
    w.use

    assert_equal  Combat::Item::ITEMS[:fire_wand][:uses] - 1, w.uses
  end

  it 'can get depleted' do
    w = Combat::Item.new_fire_wand
    Combat::Item::ITEMS[:fire_wand][:uses].times { w.use }

    assert_equal  0,  w.uses
    assert            w.depleted?
  end

  it 'cannot be used if it cannot be used!!!' do
    l = Combat::Item.new_leather_armor

    assert_raises { l.use }
  end

  it 'cannot be depleted if it cannot be used!!!' do
    s = Combat::Item.new_long_sword

    assert_raises { s.depleted? }
  end
end

