require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Monster do
  it 'creates monsters' do
    m = Combat::Monster::new_skeleton

    assert_equal    :skeleton,                              m.type

    skeleton_template = Combat::Monster::MONSTERS[m.type]

    assert_includes skeleton_template[:health_point_range], m.health_points
    assert_equal    skeleton_template[:name],               m.name
    assert_equal    skeleton_template[:defense],            m.defense
    assert_equal    skeleton_template[:magic_defense],      m.magic_defense
    
    assert_includes skeleton_template[:loot][:items],       m.drop(0.0) # 0.0 assures 100% drop
  end

  it 'attacks' do
    m   = Combat::Monster::new_warlock
    a1  = m.attack 0.3
    a2  = m.attack 0.6
    a3  = m.attack 0.9

    attacks = Combat::Monster::MONSTERS[:warlock][:attacks]

    assert_equal    "wand strike",            a1[:name]
    assert_equal    :physical,                a1[:type]
    assert_includes attacks[0][:hits_range],  a1[:hits]

    assert_equal    "fire",                   a2[:name]
    assert_equal    :magical,                 a2[:type]
    assert_includes attacks[1][:hits_range],  a2[:hits]

    assert_equal    "thunder",                a3[:name]
    assert_equal    :magical,                 a3[:type]
    assert_includes attacks[2][:hits_range],  a3[:hits]
  end
end
