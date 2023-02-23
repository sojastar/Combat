require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Actor do
  ##############################################################################
  # 1. TESTS SETUP :
  ##############################################################################
  before do
    @actor  = Combat::Actor.new(  { type:         :player,
                                    name:         'The GUY!' ,
                                    strength:      3,
                                    intelligence:  2,
                                    health:       20,
                                    mana:          5,
                                    equipment:    [],
                                    items:        [],
                                    spells:       Combat::Spell::SPELLS } )
  end


  ##############################################################################
  # 2. INITIALIZATION :
  ##############################################################################
  it 'initialises properly' do
    assert_equal  :player,    @actor.type 
    assert_equal  'The GUY!', @actor.name
    assert_equal  3,          @actor.strength
    assert_equal  2,          @actor.intelligence
    assert_equal  20,         @actor.health
    assert_equal  5,          @actor.mana

    assert_empty  @actor.equipment
    assert_empty  @actor.items

    assert_equal  Combat::Spell::SPELLS,  @actor.spells

    assert_empty  @actor.active_buffs
    assert_empty  @actor.active_ailments

    assert  @actor.can_play
  end


  ##############################################################################
  # 3. ACCESSORS :
  ##############################################################################
  it 'has initiative' do
    assert_equal 5, @actor.initiative
  end

  it 'knows if it is alive' do
    assert @actor.alive?
  end

  #it 'knows if it is dead' do
  #  @p.hit( { type: :physical_attack, damage: 25 } )

  #  assert @p.dead?
  #end


  ##############################################################################
  # 4. ACTIONS :
  ##############################################################################

  ### 4.1 Attack :
  it 'attacks with a normal weapon' do
    @actor.equipment << :long_sword
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack(attack_message).first

    assert_equal  :attack,              response[:type]
    assert_equal  @actor,               response[:parent]
    assert_equal  [ :some, :targets ],  response[:targets]

    attack  = response[:attack]

    assert_includes 0..@actor.strength, attack[:strength_damage] 
    assert_equal    [ :long_sword ],    attack[:weapons]
    assert_equal    2,                  attack[:weapon_damage]
    assert_empty                        attack[:magic_weapons]
    assert_equal    0,                  attack[:magic_damage]
    assert_empty                        attack[:ailments]
  end

  it 'attacks with magic weapons' do
    @actor.equipment << :magic_sword
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack(attack_message).first

    assert_equal  :attack,              response[:type]
    assert_equal  @actor,               response[:parent]
    assert_equal  [ :some, :targets ],  response[:targets]

    attack  = response[:attack]

    assert_includes 0..@actor.strength, attack[:strength_damage] 
    assert_equal    [ :magic_sword ],   attack[:weapons]
    assert_equal    1,                  attack[:weapon_damage]
    assert_equal    [ :magic_sword ],   attack[:magic_weapons]
    assert_equal    1,                  attack[:magic_damage]
    assert_empty                        attack[:ailments]
  end

  it 'attacks with weapons inflicting ailments' do
    @actor.equipment << :poisoned_dagger
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack(attack_message).first

    assert_equal  :attack,              response[:type]
    assert_equal  @actor,               response[:parent]
    assert_equal  [ :some, :targets ],  response[:targets]

    attack    = response[:attack]

    assert_includes 0..@actor.strength, attack[:strength_damage] 
    assert_equal    [ :poisoned_dagger ], attack[:weapons]
    assert_equal    1,                    attack[:weapon_damage]
    assert_empty                          attack[:magic_weapons]
    assert_equal    0,                    attack[:magic_damage]
    assert_equal    [ Combat::Equipment::PIECES[:poisoned_dagger][:effects].last ],
                                          attack[:ailments]
  end

  ### 4.2 Cast :
  it 'can cast magic attack spells' do
    
  end

  it 'can cast ailment spells' do
    
  end

  it 'can cast healing spells' do
    
  end

  it 'can cast buff spells' do
    
  end

  ### 4.4 Use :


  ### 4.5 Equip :


  ### 4.6 Give :


  ### 4.8 Wait :


  ##############################################################################
  # 3. REACTIONS :
  ##############################################################################

  ### 3.1 Getting hit :
  it 'gets hit with a normal weapon' do
    @actor.equipment << :leather_armor
    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack_message[:attack] = { strength_damage:  2,
                                weapons:          [ :long_sword ],
                                weapon_damage:    14,
                                magic_weapons:    [],
                                magic_damage:     0,
                                ailments:         [] }
    response                = @actor.hit(attack_message).first

    assert_equal  :got_hit,   response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil                response[:target]

    hit = response[:got_hit]
    
    assert_equal  attack_message[:attack],  hit[:hit_attack]
    assert_equal  2,                        hit[:equipment_defense]         
    assert_equal  0,                        hit[:buff_defense]
    assert_equal  14,                       hit[:physical_damage]
    assert_equal  0,                        hit[:equipment_magic_defense]
    assert_equal  0,                        hit[:buff_magic_defense]
    assert_equal  0,                        hit[:magic_damage]
    assert_equal  14,                       hit[:total_damage]

    assert_equal  @actor.max_health - hit[:total_damage], @actor.health
  end

  it 'gets hit with magic weapons' do
    @actor.equipment << :leather_armor
    @actor.equipment << :magic_helm
    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack_message[:attack] = { strength_damage:  2,
                                weapons:          [ :magic_sword ],
                                weapon_damage:    5,
                                magic_weapons:    [ :magic_sword ],
                                magic_damage:     5,
                                ailments:         [] }
    
    response                = @actor.hit(attack_message).first

    assert_equal  :got_hit,   response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil                response[:target]

    hit = response[:got_hit]
    
    assert_equal  attack_message[:attack],  hit[:hit_attack]
    assert_equal  3,                        hit[:equipment_defense] # leather armor + magic helm
    assert_equal  0,                        hit[:buff_defense]
    assert_equal  4,                        hit[:physical_damage]
    assert_equal  1,                        hit[:equipment_magic_defense]
    assert_equal  0,                        hit[:buff_magic_defense]
    assert_equal  4,                        hit[:magic_damage]
    assert_equal  8,                        hit[:total_damage]

    assert_equal  @actor.max_health - hit[:total_damage], @actor.health
  end

  it 'gets hit with ailment weapons' do
    @actor.equipment << :leather_armor
    @actor.equipment << :magic_helm
    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack_message[:attack] = { strength_damage:  2,
                                weapons:          [ :poisoned_dagger ],
                                weapon_damage:    1,
                                magic_weapons:    [],
                                magic_damage:     0,
                                ailments:         [ Combat::Equipment::PIECES[:poisoned_dagger][:effects].last ] }
    
    response  = @actor.hit(attack_message).first

    assert_equal  :got_hit,   response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil                response[:target]

    hit = response[:got_hit]
    
    assert_equal  1,      hit[:equipment_magic_defense]
    assert_equal  0,      hit[:buff_magic_defense]
    assert_equal  0,      hit[:magic_damage]
    assert_equal  0,      hit[:total_damage]

    assert_includes @actor.active_ailments,
                    Combat::Equipment::PIECES[:poisoned_dagger][:effects].last
    assert_equal    @actor.max_health - hit[:total_damage], @actor.health
  end

  ### 3.2 Getting magic hit (or hit with magic, if you prefere) :
  it 'gets hit with magic attacks' do
    magic_attack_message  = Combat::Message.new_magic_attack :a_parent, [ @actor ]
    magic_attack_message[:magic_attack] = { magic_damage: 10,
                                            ailments:     [],
                                            spell:        Combat::Spell::SPELLS[:fire_ball] }
    
    response  = @actor.got_magic_hit(magic_attack_message).first
  end

  it 'gets hit with magic attacks that also prokoke ailments' do
    
  end

  ### 3.3 Heal :
  it 'heals' do
    hit_message           = Combat::Message.new_attack :a_parent, [ @actor ]
    hit_message[:attack]  = { strength_damage:  2,
                              weapons:          [ :long_sword ],
                              weapon_damage:    12,
                              magic_weapons:    [],
                              magic_damage:     0,
                              ailments:         [] }
    hit_response          = @actor.hit(hit_message).first

    actor_health_before = @actor.health
    heal_amount         = 5
    heal_message        = Combat::Message.new_heal :another_parent, [ @actor ]
    heal_message[:heal] = { amount: heal_amount }
    response            = @actor.heal(heal_message).first

    assert_equal  :got_heal,  response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil    response[:target]

    assert_equal  actor_health_before + heal_amount,  @actor.health

    assert_equal  5,                                  response[:got_heal][:amount]
    assert_equal  actor_health_before + heal_amount,  response[:got_heal][:health]
  end

  it 'heals up to max health' do
    strength_damage       = 2
    weapon_damage         = 12
    hit_message           = Combat::Message.new_attack :a_parent, [ @actor ]
    hit_message[:attack]  = { strength_damage:  strength_damage,
                              weapons:          [ :long_sword ],
                              weapon_damage:    weapon_damage,
                              magic_weapons:    [],
                              magic_damage:     0,
                              ailments:         [] }
    hit_response          = @actor.hit(hit_message).first

    heal_amount         = strength_damage + weapon_damage + 1
    heal_message        = Combat::Message.new_heal :another_parent, [ @actor ]
    heal_message[:heal] = { amount: heal_amount }
    response            = @actor.heal(heal_message).first

    assert_equal  :got_heal,  response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil                response[:target]

    assert_equal  @actor.max_health,  @actor.health

    assert_equal  strength_damage + weapon_damage,  response[:got_heal][:amount]
    assert_equal  @actor.max_health,                response[:got_heal][:health]
  end
end
