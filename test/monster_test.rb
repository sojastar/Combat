require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Monster do
  it 'creates monsters' do
    m = Combat::Monster::new_skeleton

    assert_equal    :skeleton,                              m.type

    skeleton_template = Combat::Monster::MONSTERS[m.type]

    assert_includes skeleton_template[:health_point_range], m.health_points
    assert_equal    skeleton_template[:name],               m.name
    assert_equal    skeleton_template[:initiative],         m.initiative
    assert_equal    skeleton_template[:defense],            m.defense
    assert_equal    skeleton_template[:magic_defense],      m.magic_defense
  end

  it 'attacks' do
    m   = Combat::Monster::new_warlock
    a1  = m.attack 0.3
    a2  = m.attack 0.6
    a3  = m.attack 0.9

    attacks = Combat::Monster::MONSTERS[:warlock][:attacks]

    assert_equal    :physical_attack,         a1[:type]
    assert_equal    :monster,                 a1[:actor]
    assert_includes attacks[0][:hits_range],  a1[:damage]

    assert_equal    :magical_attack,          a2[:type]
    assert_equal    :monster,                 a2[:actor]
    assert_includes attacks[1][:hits_range],  a2[:damage]

    assert_equal    :magical_attack,          a3[:type]
    assert_equal    :monster,                 a3[:actor]
    assert_includes attacks[2][:hits_range],  a3[:damage]
  end

  it 'drops items...' do
    m = Combat::Monster::new_skeleton
    d = m.drop(0.0)   # 0.0 assures a 100% drop rate

    skeleton_template = Combat::Monster::MONSTERS[m.type]

    assert_equal    :monster_drop,                    d[:type]
    assert_equal    :monster,                         d[:actor]
    assert_includes skeleton_template[:loot][:items], d[:item]
  end

  it '... but sometimes it does not drops items' do
    m = Combat::Monster::new_skeleton
    d = m.drop(1.0)   # 1.0 assures a 0% drop rate

    assert_equal    :monster_no_drop, d[:type]
    assert_equal    :monster,         d[:actor]
  end
end
