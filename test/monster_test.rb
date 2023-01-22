require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Monster do
  it 'creates monsters' do
    s = Combat::Monster::new_skeleton

    assert_equal    :skeleton,                              s.type

    skeleton_template = Combat::Monster::MONSTERS[s.type]

    assert_includes skeleton_template[:health_point_range], s.health
    assert_equal    skeleton_template[:name],               s.name
    assert_equal    skeleton_template[:initiative],         s.initiative
    assert_equal    skeleton_template[:defense],            s.defense
    assert_equal    skeleton_template[:magic_defense],      s.magic_defense
  end

  it 'attacks' do
    w   = Combat::Monster::new_warlock
    a1  = w.attack 0.3
    a2  = w.attack 0.6
    a3  = w.attack 0.9

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

  it 'receives physical damage' do
    g = Combat::Monster::new_gobelin
    p = g.hit( { type: :physical_attack, damage: 5 } )
    
    assert_equal  :monster_get_hit,  p[:type]
    assert_equal  :monster,          p[:actor]

    assert_includes (3..7), g.health
  end

  it 'receives magic damage' do
    g = Combat::Monster::new_gobelin
    m = g.hit( { type: :magic_attack, damage: 5 } )
    
    assert_equal  :monster_get_hit,  m[:type]
    assert_equal  :monster,          m[:actor]

    assert_includes (1..5), g.health
  end

  it 'knows if it is alive' do
    g = Combat::Monster::new_gobelin
    assert g.alive?
  end

  it 'knows if it is dead' do
    g = Combat::Monster::new_gobelin
    g.hit( { type: :physical_attack, damage: 25 } )

    assert g.dead?
  end

  it 'drops items...' do
    s = Combat::Monster::new_skeleton
    d = s.drop(0.0)   # 0.0 assures a 100% drop rate

    skeleton_template = Combat::Monster::MONSTERS[s.type]

    assert_equal    :monster_drop,                    d[:type]
    assert_equal    :monster,                         d[:actor]
    assert_includes skeleton_template[:loot][:items], d[:item]
  end

  it '... but sometimes it does not drops items' do
    s = Combat::Monster::new_skeleton
    d = s.drop(1.0)   # 1.0 assures a 0% drop rate

    assert_equal    :monster_no_drop, d[:type]
    assert_equal    :monster,         d[:actor]
  end
end
