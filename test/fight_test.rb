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
    @player1.equipment[:left_hand] = :long_sword
    selection = Combat::Message.new_attack_selected @actor,
                                                    { targets: [ @enemy1 ] }
    response  = @fight.run_actor @player1, selection

    assert_equal  :attack,      response[:type]
    assert_equal  [ @enemy1 ],  response[:targets]

    attack  = response[:attack]

    assert_includes 0..@player1.strength, attack[:strength_damage] 
    assert_equal    [ :long_sword ],      attack[:weapons]
    assert_equal    2,                    attack[:weapon_damage]
    assert_empty                          attack[:magic_weapons]
    assert_equal    0,                    attack[:magic_damage]
    assert_empty                          attack[:ailments]
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
  #  @player1.equipment << :magic_sword
  #  menu_choice = Combat::Message.new_attack_selected( { targets: [ @enemy1 ],
  #                                                       param:   nil } )
  #  attack_response = @fight.run_actor @player1, menu_choice

  #  # Enemy 1 getting hit :
  #  hit_response    = @fight.run_actor @enemy1, attack_response
  #  puts '---- get_hit'
  #  pp hit_response
  #  assert_equal  attack_response[:attack],  hit_response[:get_hit][:hit_attack]
  #end
end

