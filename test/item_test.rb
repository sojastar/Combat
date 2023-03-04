require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Item do
  before do 
    @health_potion  = Combat::Item.new_health_potion
    @mana_potion    = Combat::Item.new_mana_potion
    @ambroisie      = Combat::Item.new_ambroisie
    @blowpipe       = Combat::Item.new_blowpipe
    @fire_wand      = Combat::Item.new_fire_wand
  end

  it 'creates items' do
    assert_equal  :health_potion, @health_potion.type
    assert_equal  :mana_potion,   @mana_potion.type
    assert_equal  :ambroisie,     @ambroisie.type
    assert_equal  :blowpipe,      @blowpipe.type
    assert_equal  :fire_wand,     @fire_wand.type
  end

  it 'knows its name' do
    assert_equal  'Health Potion',  @health_potion.name
    assert_equal  'Mana Potion',    @mana_potion.name
    assert_equal  'Ambroisie',      @ambroisie.name
    assert_equal  'Blowpipe',       @blowpipe.name
    assert_equal  'Fire Wand',      @fire_wand.name
  end

  it 'is used' do
    effects = @fire_wand.use

    assert_equal  Combat::Item::ITEMS[:fire_wand][:uses] - 1, @fire_wand.uses
    assert_equal  Combat::Item::ITEMS[:fire_wand][:effects],  effects
  end

  it 'can get depleted' do
    effects = nil
    Combat::Item::ITEMS[:blowpipe][:uses].times { effects = @blowpipe.use }

    assert_equal  0,                                        @blowpipe.uses
    assert                                                  @blowpipe.depleted?
    assert_equal  Combat::Item::ITEMS[:blowpipe][:effects], effects

    effect = @blowpipe.use
    assert_equal  0,  @blowpipe.uses
    assert            @blowpipe.depleted?
    assert_equal  [], effect
  end
end

