require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Player do
  before do
    @p  = Combat::Player.new  20,               # health
                              10,               # mana
                               5,               # strength
                               3,               # intelligence
                              [], 
                              #[ :long_sword ],  # starting items
                              [:fire_ball, :heal, :raise_defense]
  end

  it 'is initialized' do
    assert_equal  20,               @p.health
    assert_equal  20,               @p.max_health

    assert_equal  10,               @p.mana
    assert_equal  10,               @p.max_mana

    assert_equal   5,               @p.strength

    #assert_equal  :long_sword,      @p.items.first.type
    assert_empty                    @p.items

    assert_equal  [:fire_ball,
                   :heal,
                   :raise_defense], @p.spells
    assert_empty                    @p.active_spells
  end

  it 'has initiative' do
    assert_equal 8, @p.initiative
  end

  it 'can attack' do
    # Bare hand:
    a = @p.attack

    assert_equal    :physical_attack, a[:type]
    assert_equal    :player,          a[:actor]
    assert_includes 0..5,             a[:damage]

    # With a long sword:
    @p.receive :long_sword
    a = @p.attack

    assert_equal    :physical_attack, a[:type]
    assert_equal    :player,          a[:actor]
    assert_includes 2..7,             a[:damage]
  end

  it 'receives physical damage' do
    pa  = @p.hit( { type: :physical_attack, damage: 5 } )
    
    assert_equal  :player_get_hit,  pa[:type]
    assert_equal  :player,          pa[:actor]

    assert_equal  15, @p.health
  end

  it 'receives magic damage' do
    ma  = @p.hit( { type: :magic_attack, damage: 5 } )
    
    assert_equal  :player_get_hit,  ma[:type]
    assert_equal  :player,          ma[:actor]

    assert_equal  15, @p.health
  end

  it 'knows if it is alive' do
    assert @p.alive?
  end

  it 'knows if it is dead' do
    @p.hit( { type: :physical_attack, damage: 25 } )

    assert @p.dead?
  end

  it 'receives items' do
    r = @p.receive :mana_potion

    assert_equal    :player_get_item, r[:type]
    assert_equal    :player,          r[:actor]

    assert_equal    @p.items.last.type, :mana_potion
  end

  it 'can use a modifier item' do
    r = @p.receive  :health_potion
    i = @p.items.last   # last received item is a health potion
    h = @p.hit( { type: :physical_attack, damage: 17 } )
    u = @p.use i
 
    i_temp  = Combat::Item::ITEMS[i.type]
 
    assert_equal  :use,                             u[:type]
    assert_equal  :player,                          u[:actor]
    assert_equal  "You use the #{i_temp[:name]}.",  u[:message]

    assert_equal  1,                                      u[:effects].length
    assert_equal :use,                                    u[:effects][0][:type]
    assert_equal  0,                                      u[:effects][0][:damage]
    assert_equal  " Your health is now at #{@p.health}.", u[:effects][0][:message]

    assert_equal  13, @p.health
    assert_equal  i_temp[:uses] - 1, i.uses
  end

  it 'can use a modifier item with several stacked effects' do
    r   = @p.receive  :ambroisie
    a   = @p.items.last # last received item is ambroisie
    h   = @p.hit(      { type: :physical_attack, damage: 17 })
    c1  = @p.cast     :fire_ball
    c2  = @p.cast     :fire_ball
    u   = @p.use      a

    assert_equal  13, @p.health
    assert_equal   9, @p.mana
  end

  it 'can use an attack item' do
    r = @p.receive  :blowpipe
    i = @p.items.last
    u = @p.use i
 
    i_temp  = Combat::Item::ITEMS[i.type]

    assert_equal  :use,                             u[:type]
    assert_equal  :player,                          u[:actor]
    assert_equal  "You use the #{i_temp[:name]}.",  u[:message]

    assert_equal    1,                                            u[:effects].length
    assert_equal    :attack,                                      u[:effects][0][:type]
    assert_includes i_temp[:effects].first[:hits_range],          u[:effects][0][:damage]
    assert_equal    " You deal #{u[:effects][0][:damage]} hits!", u[:effects][0][:message]

    assert_equal  i_temp[:uses] - 1, i.uses 
  end

  it 'can use a magic attack item' do
    r = @p.receive  :fire_wand
    i = @p.items.last
    u = @p.use i
 
    i_temp  = Combat::Item::ITEMS[i.type]

    assert_equal  :use,                             u[:type]
    assert_equal  :player,                          u[:actor]
    assert_equal  "You use the #{i_temp[:name]}.",  u[:message]

    assert_equal    1,                                            u[:effects].length
    assert_equal    :magic_attack,                                u[:effects][0][:type]
    assert_includes i_temp[:effects].first[:hits_range],          u[:effects][0][:damage]
    assert_equal    " You deal #{u[:effects][0][:damage]} hits!", u[:effects][0][:message]

    assert_equal  i_temp[:uses] - 1, i.uses 
  end
end
