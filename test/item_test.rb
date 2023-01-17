require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Item do
  it 'creates items' do
    h = Combat::Item.new_health_potion
    m = Combat::Item.new_mana_potion
    w = Combat::Item.new_fire_wand

    item_templates  = Combat::Item::ITEMS

    assert_equal  :health_potion,                 h.type
    assert_equal  item_templates[h.type][:uses],  h.uses

    assert_equal  :mana_potion,                   m.type
    assert_equal  item_templates[m.type][:uses],  m.uses
    
    assert_equal  :fire_wand,                     w.type
    assert_equal  item_templates[w.type][:uses],  w.uses
  end
end

