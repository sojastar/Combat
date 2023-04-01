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
    # Player 1 setup :
    equipment_id                    = :evil_sword   # a weapon that does it all
    equipment                       = Combat::Equipment::PIECES[equipment_id]
    ailment                         = { source: equipment_id,
                                        effect: equipment[:effects][2] }
    @player1.equipment[:left_hand]  = equipment_id

    attack_buff       = { source: 'War Cry', on: :attack, value: 2, turns: 3 }
    magic_attack_buff = { source: 'Secret Ritual', on: :magic_attack, value: 1, turns: 3 }
    @player1.active_buffs << attack_buff << magic_attack_buff

    # Player 1 attacking :
    selection = Combat::Message.new_attack_selected @actor,
                                                    { targets:  [ @enemy1 ],
                                                      param:    nil }
    attack_response  = @fight.run_actor @player1, selection

    # Tests :
    assert_equal  :attack,      attack_response[:type]
    assert_equal  [ @enemy1 ],  attack_response[:targets]

    attack  = attack_response[:attack]

    assert_includes 0..@player1.strength,           attack[:strength_damage] 
    assert_equal    attack_buff[:value],            attack[:attack_buff_damage]
    assert_equal    [ equipment_id ],               attack[:weapons]
    assert_equal    equipment[:effects][0][:value], attack[:weapon_damage]
    assert_equal    [ equipment_id ],               attack[:magic_weapons]
    assert_equal    equipment[:effects][1][:value], attack[:magic_damage]
    assert_equal    magic_attack_buff[:value],      attack[:magic_attack_buff_damage]
    assert_equal    [ ailment ],                    attack[:ailments]
  end

  ### 3.2 CASTING SPELLS : #####################################################
  it 'produces a magic attack message when a magic attack spell is cast' do
    # Player 1 setup :
    magic_attack_buff = { source: 'Secret Ritual', on: :magic_attack, value: 1, turns: 3 }
    @player1.active_buffs << magic_attack_buff

    # Player 1 casting a magic attack :
    spell_id  = :fire_ball
    spell     = Combat::Spell::SPELLS[spell_id]
    selection = Combat::Message.new_cast_selected @actor,
                                                  { targets:  [ @enemy1 ],
                                                    param:    spell_id }
    cast_response = @fight.run_actor @player1, selection

    # Tests :
    assert_equal  :cast,        cast_response[:type]
    assert_equal  [ @enemy1 ],  cast_response[:targets]

    cast = cast_response[:cast]

    assert_equal spell_id,  cast[:spell]
    assert_equal 1,         cast[:submessages].length

    magic_attack_submessage = cast[:submessages][0]

    assert_equal  :magic_attack,  magic_attack_submessage[:type]
    assert_equal  @player1,       magic_attack_submessage[:parent]
    assert_equal  [ @enemy1 ],    magic_attack_submessage[:targets ]

    magic_attack = magic_attack_submessage[:magic_attack]

    assert_includes spell[:effects][0][:value], magic_attack[:magic_damage]
    assert_equal    magic_attack_buff[:value],  magic_attack[:magic_attack_buff_damage]
    assert_empty                                magic_attack[:ailments]  
    assert_equal    spell_id,                   magic_attack[:source]
  end

  it 'produces a heal message when a healing spell is cast' do
    spell_id  = :heal
    spell     = Combat::Spell::SPELLS[spell_id]
    selection = Combat::Message.new_cast_selected @actor,
                                                  { targets:  [ @player2 ],
                                                    param:    spell_id }
    cast_response = @fight.run_actor @player1, selection

    # Tests :
    assert_equal  :cast,        cast_response[:type]
    assert_equal  [ @player2 ], cast_response[:targets]

    cast = cast_response[:cast]

    assert_equal spell_id,  cast[:spell]
    assert_equal 1,         cast[:submessages].length

    heal_submessage = cast[:submessages][0]

    assert_equal  :heal,        heal_submessage[:type]
    assert_equal  @player1,     heal_submessage[:parent]
    assert_equal  [ @player2 ], heal_submessage[:targets ]

    heal = heal_submessage[:heal]

    assert_includes spell[:effects][0][:value], heal[:amount]
    assert_equal    spell_id,                   heal[:source]
  end

  it 'produces an add mana message when an add mana spell is cast' do
    
  end

  it 'produces a buff message when a buff spell is cast' do
    
  end

  it 'produces a ailment message when a ailment spell is cast' do
    
  end

  #it 'produces a cast message/response when the actor selects cast' do
  #  menu_choice = Combat::Message.new_cast_selected(  { targets: [ @enemy1 ],
  #                                                      param:   :fire_ball } )
  #  response    = @fight.run_actor @player1, menu_choice


  # end


  ##############################################################################
  # 4. RUNNING ATOMIC REACTIONS :
  ##############################################################################

  ### 4.1. GET HIT : ###########################################################
  it 'runs hits (i.e. received damage)' do
    # Player 1 attacking :
    attack_equipment                = :evil_sword
    @player1.equipment[:left_hand]  = attack_equipment
    menu_choice = Combat::Message.new_attack_selected @actor,
                                                      { targets:  [ @enemy1 ],
                                                        param:    nil }
    attack_response = @fight.run_actor @player1, menu_choice

    # Enemy 1 getting hit :
    defense_equipment         = :magic_helm
    @enemy1.equipment[:head]  = defense_equipment
    hit_response    = @fight.run_actor @enemy1, attack_response

    assert_equal  :got_hit, hit_response[:type]
    assert_equal  @enemy1,  hit_response[:parent]
    assert_nil              hit_response[:targets]

    hit     = hit_response[:got_hit]
    attack  = attack_response[:attack]

    assert_equal  attack_response[:attack], hit[:hit_attack]
    assert_equal  Combat::Equipment::PIECES[defense_equipment][:effects][0][:value],
                                            hit[:equipment_defense]
    assert_equal  0,                        hit[:buff_defense]
    assert_equal  attack[:strength_damage]  +
                  attack[:weapon_damage]    -
                  hit[:equipment_defense]   -
                  hit[:buff_defense],       hit[:physical_damage]
    assert_equal  Combat::Equipment::PIECES[defense_equipment][:effects][1][:value],
                                            hit[:equipment_magic_defense]
    assert_equal  0,                        hit[:buff_magic_defense]
    assert_equal  attack[:magic_damage]         -
                  hit[:equipment_magic_defense] -
                  hit[:buff_magic_defense], hit[:magic_damage]
    assert        same_effect?( @enemy1.active_effect_from( attack[:ailments][0][:source],
                                                            attack[:ailments][0][:effect] ),
                                hit[:ailments][0] )
    assert_equal  hit[:physical_damage] +
                  hit[:magic_damage],       hit[:total_damage]
  end
end

