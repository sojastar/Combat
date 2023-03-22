require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Fight do
  ##############################################################################
  # 1. TESTS SETUP :
  ##############################################################################
  before do
    @player1    = Combat::Actor.new(  { type:         :player,
                                        name:         'Player 1' ,
                                        strength:      3,
                                        intelligence:  2,
                                        health:       20,
                                        mana:          5,
                                        equipment:    { head:       nil,
                                                        neck:       nil,
                                                        left_hand:  nil,
                                                        right_hand: nil,
                                                        torso:      nil,
                                                        legs:       nil },
                                        items:        [],
                                        spells:       Combat::Spell::SPELLS } )
    @player2    = Combat::Actor.new(  { type:         :player,
                                        name:         'Player2' ,
                                        strength:      3,
                                        intelligence:  2,
                                        health:       20,
                                        mana:          5,
                                        equipment:    { head:       nil,
                                                        neck:       nil,
                                                        left_hand:  nil,
                                                        right_hand: nil,
                                                        torso:      nil,
                                                        legs:       nil },
                                        items:        [],
                                        spells:       Combat::Spell::SPELLS } )
    @enemy1   = Combat::Actor.new(  { type:         :player,
                                      name:         'Enemy 1' ,
                                      strength:      3,
                                      intelligence:  2,
                                      health:       20,
                                      mana:          5,
                                      equipment:    { head:       nil,
                                                      neck:       nil,
                                                      left_hand:  nil,
                                                      right_hand: nil,
                                                      torso:      nil,
                                                      legs:       nil },
                                      items:        [],
                                      spells:       Combat::Spell::SPELLS } )
    @enemy2   = Combat::Actor.new(  { type:         :player,
                                      name:         'Enemy 2' ,
                                      strength:      3,
                                      intelligence:  2,
                                      health:       20,
                                      mana:          5,
                                      equipment:    { head:       nil,
                                                      neck:       nil,
                                                      left_hand:  nil,
                                                      right_hand: nil,
                                                      torso:      nil,
                                                      legs:       nil },
                                      items:        [],
                                      spells:       Combat::Spell::SPELLS } )
    @players    = [ @player1, @player2 ]
    @opponents  = [ @enemy1, @enemy2 ]
    @fight      = Combat::Fight.new @players, @opponents
  end


  ##############################################################################
  # 2. INITIALIZATION :
  ##############################################################################
  it 'initialises properly' do
    assert_equal  @players,               @fight.players
    assert_equal  @opponents,             @fight.opponents
    assert_equal  @players + @opponents,  @fight.actors
  end


  ##############################################################################
  # 3. RUNNING ATOMIC ACTIONS :
  ##############################################################################

  ### 3.1. ATTACKS : ###########################################################
  it 'produces an attack message/response when the actor selects attack' do
    # Player 1 attacking :
    evil_sword                      = Combat::Equipment::PIECES[:evil_sword]
    @player1.equipment[:left_hand]  = :evil_sword  # a weapon that does it all

    selection = Combat::Message.new_attack_selected @actor,
                                                    { targets:  [ @enemy1 ],
                                                      param:    nil }
    attack_response  = @fight.run_actor @player1, selection

    assert_equal  :attack,      attack_response[:type]
    assert_equal  [ @enemy1 ],  attack_response[:targets]

    attack  = attack_response[:attack]

    assert_includes 0..@player1.strength,             attack[:strength_damage] 
    assert_equal    [ :evil_sword ],                  attack[:weapons]
    assert_equal    evil_sword[:effects][0][:value],  attack[:weapon_damage]
    assert_equal    [ :evil_sword ],                  attack[:magic_weapons]
    assert_equal    evil_sword[:effects][1][:value],  attack[:magic_damage]
    assert_equal    @player1.active_effect_from( :evil_sword, evil_sword[:effects][2] ),
                                                      attack[:ailments]
  end

  ### 3.2 CASTING SPELLS : #####################################################
  #it 'produces a cast message/response when the actor selects cast' do
  #  menu_choice = Combat::Message.new_cast_selected(  { targets: [ @enemy1 ],
  #                                                      param:   :fire_ball } )
  #  response    = @fight.run_actor @player1, menu_choice


  # end


  ##############################################################################
  # 4. RUNNING ATOMIC REACTIONS :
  ##############################################################################

  ### 4.1. GET HIT : ###########################################################
  #it 'runs hits (i.e. received damage)' do
  #  # Player 1 attacking :
  #  attack_equipment                = :evil_sword
  #  @player1.equipment[:left_hand]  = attack_equipment
  #  menu_choice = Combat::Message.new_attack_selected @actor,
  #                                                    { targets:  [ @enemy1 ],
  #                                                      param:    nil }
  #  attack_response = @fight.run_actor @player1, menu_choice

  #  # Enemy 1 getting hit :
  #  defense_equipment         = :magic_helm
  #  @enemy1.equipment[:head]  = defense_equipment
  #  hit_response    = @fight.run_actor @enemy1, attack_response

  #  assert_equal  :got_hit, hit_response[:type]
  #  assert_equal  @enemy1,  hit_response[:parent]
  #  assert_nil              hit_response[:targets]

  #  hit     = hit_response[:got_hit]
  #  attack  = attack_response[:attack]
  #  #pp hit
  #  assert_equal  attack_response[:attack], hit[:hit_attack]
  #  assert_equal  Combat::Equipment::PIECES[defense_equipment][:effects][0][:value],
  #                                          hit[:equipment_defense]
  #  assert_equal  0,                        hit[:buff_defense]
  #  assert_equal  attack[:strength_damage]  +
  #                attack[:weapon_damage]    -
  #                hit[:equipment_defense]   -
  #                hit[:buff_defense],       hit[:physical_damage]
  #  assert_equal  Combat::Equipment::PIECES[defense_equipment][:effects][1][:value],
  #                                          hit[:equipment_magic_defense]
  #  assert_equal  0,                        hit[:buff_magic_defense]
  #  assert_equal  0,                        hit[:magic_damage]
  #  assert_empty                            hit[:ailments]
  #  assert_equal  hit[:physical_damage] +
  #                hit[:magic_damage],       hit[:total_damage]
  #end
end

