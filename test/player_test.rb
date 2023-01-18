require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Player do
  before do
    @p  = Combat::Player.new  20,             # health
                              10,             # mana
                               5,             # strength
                               3,             # intelligence
                               2,             # defense 
                               0,             # magic_defense
                              [ :long_sword ] # strating items
  end

  it 'is initialized' do
    assert_equal  20,               @p.health
    assert_equal  20,               @p.max_health

    assert_equal  10,               @p.mana
    assert_equal  10,               @p.max_mana

    assert_equal   5,               @p.strength
    assert_equal   2,               @p.defense
    assert_equal   0,               @p.magic_defense

    assert_equal  :long_sword,  @p.items.first.type
  end

  it 'can attack' do
    a = @p.attack

    assert_equal    :physical_attack, a[:type]
    assert_equal    :player,          a[:actor]
    assert_includes 2..7,             a[:damage]
  end

  it 'receives physical damage' do
    p = @p.get_hit( { type: :physical_attack, damage: 5 } )
    
    assert_equal  :player_get_hit,  p[:type]
    assert_equal  :player,          p[:actor]

    assert_equal  17, @p.health
  end

  it 'receives magic damage' do
    m = @p.get_hit( { type: :magic_attack, damage: 5 } )
    
    assert_equal  :player_get_hit,  m[:type]
    assert_equal  :player,          m[:actor]

    assert_equal  15, @p.health
  end

  it 'knows if it is dead' do
    @p.get_hit( { type: :physical_attack, damage: 25 } )

    assert @p.is_dead?
  end

  it 'receives items' do
    r = @p.receive :mana_potion

    assert_equal    :player_get_item, r[:type]
    assert_equal    :player,          r[:actor]

    assert_equal    @p.items.last.type, :mana_potion
  end

  it 'can use a modifier item' do
    r = @p.receive  :health_potion
    h = @p.get_hit( { type: :physical_attack, damage: 17 } )
    i = @p.items.last
    u = @p.use i
 
    assert_equal  :player_use_object, u[:type]
    assert_equal  :player,            u[:actor]
    assert_equal  0,                  u[:damage]

    assert_equal  15, @p.health
    assert_equal  Combat::Item::ITEMS[i.type][:uses] - 1, i.uses
  end

  it 'can use an attack item' do
    r = @p.receive  :blowpipe
    i = @p.items.last
    u = @p.use i
 
    i_temp  = Combat::Item::ITEMS[i.type]

    assert_equal    :player_use_attack_object,            u[:type]
    assert_equal    :player,                              u[:actor]
    assert_includes i_temp[:effects].first[:hits_range],  u[:damage]

    assert_equal  i_temp[:uses] - 1, i.uses 
  end

  it 'can use a magic attack item' do
    r = @p.receive  :fire_wand
    i = @p.items.last
    u = @p.use i
 
    i_temp  = Combat::Item::ITEMS[i.type]

    assert_equal    :player_use_magic_attack_object,      u[:type]
    assert_equal    :player,                              u[:actor]
    assert_includes i_temp[:effects].first[:hits_range],  u[:damage]

    assert_equal  i_temp[:uses] - 1, i.uses 
  end
end
