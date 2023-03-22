require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Actor do
  ##############################################################################
  # 1. TESTS SETUP :
  ##############################################################################
  before do
    @no_equipment = { head:       nil,
                      neck:       nil,
                      left_hand:  nil,
                      right_hand: nil,
                      torso:      nil,
                      legs:       nil }
    @actor  = Combat::Actor.new(  { type:         :player,
                                    name:         'The GUY!' ,
                                    strength:     3,
                                    intelligence: 2,
                                    health:       20,
                                    mana:         5,
                                    equipment:    @no_equipment,
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

    assert_equal  @no_equipment,  @actor.equipment
    assert_empty                  @actor.equipment_stash

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


  ############################################################################
  # 4. EFFECTS, BUFFS and AILMENTS :
  ############################################################################
  it 'makes active buffs from spell effects' do
    spell         = Combat::Spell::SPELLS[:raise_magic_defense]
    spell_effect  = spell[:effects].first
    active_effect = @actor.active_effect_from spell[:name], spell_effect

    assert_equal    spell[:name],         active_effect[:source]
    assert_equal    spell_effect[:on],    active_effect[:on]
    assert_includes spell_effect[:value], active_effect[:value]
    assert_equal    spell_effect[:turns], active_effect[:turns]
  end

  it 'makes active ailments from equipment effects' do
    equipment_id      = :poisoned_dagger
    equipment         = Combat::Equipment::PIECES[equipment_id]
    equipment_effect  = equipment[:effects].last
    active_effect     = @actor.active_effect_from equipment_id,
                                                  equipment_effect

    assert_equal    equipment_id,             active_effect[:source]
    assert_equal    equipment_effect[:on],    active_effect[:on]
    assert_includes equipment_effect[:value], active_effect[:value]
    assert_equal    equipment_effect[:turns], active_effect[:turns]
  end

  it 'makes active ailments from spell effects' do
    spell         = Combat::Spell::SPELLS[:poison]
    spell_effect  = spell[:effects].first
    active_effect = @actor.active_effect_from spell[:name], spell_effect

    assert_equal    spell[:name],         active_effect[:source]
    assert_equal    spell_effect[:on],    active_effect[:on]
    assert_includes spell_effect[:value], active_effect[:value]
    assert_equal    spell_effect[:turns], active_effect[:turns]
  end

  it 'pushs new buffs to the corresponding active array' do
    other_buff1   = { name: 'war cry',        on: :attack,        value: 0, turns: 3 }
    other_buff2   = { name: 'magic barrier',  on: :magic_attack,  value: 0, turns: 4 }
    buff          = { name: 'shield',         on: :defense,       value: 2, turns: 2 }
    weaker_buff   = { name: 'shield',         on: :defense,       value: 1, turns: 2 }
    stronger_buff = { name: 'shield',         on: :defense,       value: 3, turns: 3 }

    @actor.push_effect_to other_buff1, @actor.active_buffs
    @actor.push_effect_to buff,        @actor.active_buffs
    @actor.push_effect_to other_buff2, @actor.active_buffs

    # Pushing a weaker buff won't change anything :
    @actor.push_effect_to weaker_buff, @actor.active_buffs

    assert_equal 3,               @actor.active_buffs.length
    assert_equal buff[:value], @actor.active_buffs[1][:value]
    assert_equal buff[:turns], @actor.active_buffs[1][:turns]

    # Pushng a stronger buff will replace the current buff and reset...
    # ... the turn counter :
    @actor.push_effect_to stronger_buff, @actor.active_buffs

    assert_equal 3,                         @actor.active_buffs.length
    assert_equal stronger_buff[:value],  @actor.active_buffs[1][:value]
    assert_equal stronger_buff[:turns],  @actor.active_buffs[1][:turns]
  end

  it 'pushes new ailments to the corresponding active array' do
    other_ailment1    = { name: 'Sleep',  on: :sleep,  value: 0, turns: 3 }
    other_ailment2    = { name: 'Drunk',  on: :drunk,  value: 0, turns: 4 }
    ailment           = { name: 'Poison', on: :health, value: 2, turns: 2 }
    weaker_ailment    = { name: 'Poison', on: :health, value: 1, turns: 2 }
    stronger_ailment  = { name: 'Poison', on: :health, value: 3, turns: 3 }

    @actor.push_effect_to other_ailment1, @actor.active_ailments
    @actor.push_effect_to ailment,        @actor.active_ailments
    @actor.push_effect_to other_ailment2, @actor.active_ailments

    # Pushing a weaker ailment won't change anything :
    @actor.push_effect_to weaker_ailment, @actor.active_ailments

    assert_equal 3,               @actor.active_ailments.length
    assert_equal ailment[:value], @actor.active_ailments[1][:value]
    assert_equal ailment[:turns], @actor.active_ailments[1][:turns]

    # Pushng a stronger ailment will replace the current ailment and reset...
    # ... the turn counter :
    @actor.push_effect_to stronger_ailment, @actor.active_ailments

    assert_equal 3,                         @actor.active_ailments.length
    assert_equal stronger_ailment[:value],  @actor.active_ailments[1][:value]
    assert_equal stronger_ailment[:turns],  @actor.active_ailments[1][:turns]
  end


  ##############################################################################
  # 5. ACTIONS :
  ##############################################################################

  ### 5.1 Attack :
  it 'attacks with a normal weapon' do
    @actor.equipment[:right_hand] = :long_sword
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack attack_message

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
    @actor.equipment[:right_hand] = :magic_sword
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack attack_message

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
    @actor.equipment[:right_hand] = :poisoned_dagger
    menu_selection  = { targets: [ :some, :targets ] }
    attack_message  = Combat::Message.new_attack_selected @actor, menu_selection
    response        = @actor.attack attack_message

    assert_equal  :attack,              response[:type]
    assert_equal  @actor,               response[:parent]
    assert_equal  [ :some, :targets ],  response[:targets]

    attack    = response[:attack]

    assert_includes 0..@actor.strength, attack[:strength_damage] 
    assert_equal    [ :poisoned_dagger ], attack[:weapons]
    assert_equal    1,                    attack[:weapon_damage]
    assert_empty                          attack[:magic_weapons]
    assert_equal    0,                    attack[:magic_damage]
    assert_equal    [ { source: :poisoned_dagger,
                        effect: Combat::Equipment::PIECES[:poisoned_dagger][:effects].last } ],
                                          attack[:ailments]
  end

  ### 5.2 Cast :
  it 'casts magic attack spells' do
    spell_id        = :fire_ball
    spell           = Combat::Spell::SPELLS[spell_id]

    menu_selection  = { targets: [ :some, :targets ], param: spell_id }
    cast_message    = Combat::Message.new_cast_selected @actor, menu_selection   
    response        = @actor.cast cast_message

    assert_equal  :cast,                    response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  spell_id, response[:cast][:spell]
    assert_equal  1,        response[:cast][:submessages].length
    
    submessage  = response[:cast][:submessages].first
    assert_equal    :magic_attack,                  submessage[:type]
    assert_equal    @actor,                         submessage[:parent]
    assert_equal    menu_selection[:targets],       submessage[:targets]
    assert_includes spell[:effects].first[:value],  submessage[:magic_attack][:magic_damage] 
    assert_equal    spell_id,                       submessage[:magic_attack][:spell]
  end

  it 'casts healing spells' do
    spell_id        = :heal
    spell           = Combat::Spell::SPELLS[spell_id]

    menu_selection  = { targets: [ :some, :targets ], param: spell_id }
    cast_message    = Combat::Message.new_cast_selected @actor, menu_selection   
    response        = @actor.cast cast_message

    assert_equal  :cast,                    response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  spell_id, response[:cast][:spell]
    assert_equal  1,        response[:cast][:submessages].length
    
    submessage  = response[:cast][:submessages].first
    assert_equal    :heal,                          submessage[:type]
    assert_equal    @actor,                         submessage[:parent]
    assert_equal    menu_selection[:targets],       submessage[:targets]
    assert_includes spell[:effects].first[:value],  submessage[:heal][:amount]
    assert_equal    spell_id,                       submessage[:heal][:source]
  end

  it 'casts buff spells' do
    spell_id        = :raise_defense
    spell           = Combat::Spell::SPELLS[spell_id]
    ailment         = @actor.active_effect_from spell_id,
                                                spell[:effects].first

    menu_selection  = { targets: [ :some, :targets ], param: spell_id }
    cast_message    = Combat::Message.new_cast_selected @actor, menu_selection   
    response        = @actor.cast cast_message

    assert_equal  :cast,                    response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  spell_id, response[:cast][:spell]
    assert_equal  1, response[:cast][:submessages].length
    
    submessage  = response[:cast][:submessages].first
    assert_equal  :add_buff,                submessage[:type]
    assert_equal  @actor,                   submessage[:parent]
    assert_equal  menu_selection[:targets], submessage[:targets]
    assert        same_effect?(ailment, submessage[:add_buff])
  end

  it 'casts ailment spells' do
    spell_id        = :poison
    spell           = Combat::Spell::SPELLS[spell_id]
    ailment         = @actor.active_effect_from spell_id,
                                                spell[:effects].first

    menu_selection  = { targets: [ :some, :targets ], param: spell_id }
    cast_message    = Combat::Message.new_cast_selected @actor, menu_selection   
    response        = @actor.cast cast_message

    assert_equal  :cast,                    response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  spell_id, response[:cast][:spell]
    assert_equal  1,        response[:cast][:submessages].length
    
    submessage  = response[:cast][:submessages].first
    assert_equal  :add_ailment,             submessage[:type]
    assert_equal  @actor,                   submessage[:parent]
    assert_equal  menu_selection[:targets], submessage[:targets]
    assert        same_effect?(ailment, submessage[:add_ailment])
  end

  it 'casts spells with several effects' do
    spell_id        = :toxic_sleep
    spell           = Combat::Spell::SPELLS[spell_id]
    ailments        = spell[:effects].map do |effect|
                        @actor.active_effect_from spell_id, effect
                      end

    menu_selection  = { targets: [ :some, :targets ], param: spell_id }
    cast_message    = Combat::Message.new_cast_selected @actor, menu_selection   
    response        = @actor.cast cast_message

    assert_equal  :cast,                    response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  spell_id, response[:cast][:spell]
    assert_equal  2,        response[:cast][:submessages].length
    
    first_submessage  = response[:cast][:submessages].first
    assert_equal  :add_ailment,               first_submessage[:type]
    assert_equal  @actor,                     first_submessage[:parent]
    assert_equal  menu_selection[:targets],   first_submessage[:targets]
    assert        same_effect?(ailments.first, first_submessage[:add_ailment])
    
    second_submessage = response[:cast][:submessages].last
    assert_equal  :add_ailment,               second_submessage[:type]
    assert_equal  @actor,                     second_submessage[:parent]
    assert_equal  menu_selection[:targets],   second_submessage[:targets]
    assert        same_effect?(ailments.last,  second_submessage[:add_ailment])
  end

  ### 5.3 Use :
  it 'uses healing items' do
    item = Combat::Item.new_health_potion
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1, response[:use][:submessages].length

    heal_message  = response[:use][:submessages].first

    assert_equal    :heal,                      heal_message[:type]
    assert_equal    @actor,                     heal_message[:parent]
    assert_equal    menu_selection[:targets],   heal_message[:targets]
    assert_includes item.effects.first[:value], heal_message[:heal][:amount]
    assert_equal    item.type,                  heal_message[:heal][:source]
  end

  it 'uses mana refill items' do
    item = Combat::Item.new_mana_potion
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1, response[:use][:submessages].length

    heal_message  = response[:use][:submessages].first

    assert_equal    :add_mana,                  heal_message[:type]
    assert_equal    @actor,                     heal_message[:parent]
    assert_equal    menu_selection[:targets],   heal_message[:targets]
    assert_includes item.effects.first[:value], heal_message[:add_mana][:amount]
    assert_equal    item.type,                  heal_message[:add_mana][:source]
  end

  it 'uses items with multiple effects' do
    item = Combat::Item.new_ambroisie
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  2, response[:use][:submessages].length

    submessage1 = response[:use][:submessages].first

    assert_equal    :heal,                      submessage1[:type]
    assert_equal    @actor,                     submessage1[:parent]
    assert_equal    menu_selection[:targets],   submessage1[:targets]
    assert_includes item.effects.first[:value], submessage1[:heal][:amount]
    assert_equal    item.type,                  submessage1[:heal][:source]

    submessage2 = response[:use][:submessages].last

    assert_equal    :add_mana,                  submessage2[:type]
    assert_equal    @actor,                     submessage2[:parent]
    assert_equal    menu_selection[:targets],   submessage2[:targets]
    assert_includes item.effects.last[:value],  submessage2[:add_mana][:amount]
    assert_equal    item.type,                       submessage2[:add_mana][:source]
  end

  it 'uses attack items' do
    item = Combat::Item.new_blowpipe
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1, response[:use][:submessages].length

    attack_message = response[:use][:submessages].first

    assert_equal    :attack,                    attack_message[:type]
    assert_equal    @actor,                     attack_message[:parent]
    assert_equal    menu_selection[:targets],   attack_message[:targets]

    attack = attack_message[:attack]

    assert_equal    0,              attack[:strength_damage] 
    assert_equal    [ item.type ],  attack[:weapons]
    assert_includes Combat::Item::ITEMS[item.type][:effects].first[:value],
                                    attack[:weapon_damage]
    assert_empty                    attack[:magic_weapons]
    assert_equal    0,              attack[:magic_damage]
    assert_empty                    attack[:ailments]
  end

  it 'uses attack and ailment items' do
    item = Combat::Item.new_poisoned_blowpipe
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  2, response[:use][:submessages].length

    attack_message = response[:use][:submessages][0]

    assert_equal    :attack,                    attack_message[:type]
    assert_equal    @actor,                     attack_message[:parent]
    assert_equal    menu_selection[:targets],   attack_message[:targets]

    attack = attack_message[:attack]

    assert_equal    0,              attack[:strength_damage] 
    assert_equal    [ item.type ],  attack[:weapons]
    assert_includes Combat::Item::ITEMS[item.type][:effects][0][:value],
                                    attack[:weapon_damage]
    assert_empty                    attack[:magic_weapons]
    assert_equal    0,              attack[:magic_damage]
    assert_empty                    attack[:ailments]

    ailment_message = response[:use][:submessages][1][:add_ailment]
    ailment         = Combat::Item::ITEMS[item.type][:effects][1]

    assert_equal    item.type,        ailment_message[:source]
    assert_equal    ailment[:name],   ailment_message[:name]
    assert_includes ailment[:value],  ailment_message[:value]
    assert_equal    ailment[:on],     ailment_message[:on]
    assert_equal    ailment[:turns],  ailment_message[:turns]
  end

  it 'uses magic attack items' do
    item =  Combat::Item.new_fire_wand
    @actor.items << item
    
    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1, response[:use][:submessages].length

    magic_attack_message = response[:use][:submessages].first

    assert_equal    :magic_attack,              magic_attack_message[:type]
    assert_equal    @actor,                     magic_attack_message[:parent]
    assert_equal    menu_selection[:targets],   magic_attack_message[:targets]

    magic_attack = magic_attack_message[:magic_attack]

    assert_includes Combat::Item::ITEMS[:fire_wand][:effects].first[:value],
                                magic_attack[:magic_damage]
    assert_empty                magic_attack[:ailments]
    assert_equal    item.type,  magic_attack[:spell]
  end

  it 'uses items that provoke ailments' do
    item = Combat::Item.new_poison_wand
    @actor.items << item

    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1,            response[:use][:submessages].length
    assert_equal  :add_ailment, response[:use][:submessages].first[:type]

    ailment_message = response[:use][:submessages].first[:add_ailment]
    ailment         = Combat::Item::ITEMS[item.type][:effects].first

    assert_equal    item.type,        ailment_message[:source]
    assert_equal    ailment[:name],   ailment_message[:name]
    assert_includes ailment[:value],  ailment_message[:value]
    assert_equal    ailment[:on],     ailment_message[:on]
    assert_equal    ailment[:turns],  ailment_message[:turns]
  end

  it 'uses buff items' do
    item = Combat::Item.new_attack_potion
    @actor.items << item

    menu_selection  = { targets: [ :some, :targets ], param: item }
    use_message     = Combat::Message.new_use_selected @actor, menu_selection
    response        = @actor.use use_message 

    assert_equal  :use,                     response[:type]
    assert_equal  @actor,                   response[:parent]
    assert_equal  menu_selection[:targets], response[:targets]

    assert_equal  1,          response[:use][:submessages].length
    assert_equal  :add_buff,  response[:use][:submessages].first[:type]

    buff_message  = response[:use][:submessages].first[:add_buff]
    buff          = Combat::Item::ITEMS[item.type][:effects].first

    assert_equal    item.type,      buff_message[:source]
    assert_equal    buff[:on],      buff_message[:on]
    assert_includes buff[:value],   buff_message[:value]
    assert_equal    buff[:turns],   buff_message[:turns]
  end

  ### 5.4 Equip :
  it 'equips equipment' do
    equipment       = :long_sword
    body_part       = :left_hand
    menu_selection  = { targets:  [ :some, :targets ],
                        param:    { equipment:  equipment,
                                    body_part:  body_part } }
    equip_message   = Combat::Message.new_equip_selected @actor, menu_selection
    response        = @actor.equip equip_message

    assert_equal  equipment, @actor.equipment[:left_hand]

    assert_equal  :equiped,     response[:type]
    assert_equal  @actor,       response[:parent]
    assert_nil                  response[:target]
    assert_equal  :long_sword,  response[:equiped][:equipment]
  end

  ### 5.5 Give :
  it 'gives items' do
    item            = Combat::Item.new_health_potion
    @actor.items << item
    menu_selection  = { targets:  [ :a_target ],
                        param:    { gift:   item,
                                    stash:  :items } }
    give_message    = Combat::Message.new_give_selected @actor, menu_selection
    response        = @actor.give give_message
    
    assert_equal  :give,          response[:type]
    assert_equal  @actor,         response[:parent]
    assert_equal  [ :a_target ],  response[:targets]

    refute_includes @actor.items, item

    assert_equal  item,   response[:give][:gift]
    assert_equal  :items, response[:give][:stash]
  end

  it 'gives equipment' do
    equipment = :long_sword
    @actor.equipment_stash << equipment
    menu_selection  = { targets:  [ :a_target ],
                        param:    { gift:   equipment,
                                    stash:  :equipment } }
    give_message    = Combat::Message.new_give_selected @actor, menu_selection
    response        = @actor.give give_message
    
    assert_equal  :give,          response[:type]
    assert_equal  @actor,         response[:parent]
    assert_equal  [ :a_target ],  response[:targets]

    refute_includes @actor.equipment_stash, equipment

    assert_equal  equipment,  response[:give][:gift]
    assert_equal  :equipment, response[:give][:stash]
  end

  ### 5.6 Wait :
  it 'waits' do
    wait_message  = Combat::Message.new_wait :a_parent, [ :useless_target ]
    response = @actor.wait wait_message

    assert_equal  :waited,  response[:type]
    assert_equal  @actor,   response[:parent]
    assert_nil              response[:target]
  end


  ##############################################################################
  # 6. REACTIONS :
  ##############################################################################

  ### 6.1 Getting hit :
  it 'gets hit with a normal weapon' do
    # Preping the actor :
    armor_id  = :leather_armor
    armor     = Combat::Equipment::PIECES[armor_id][:effects].first
    @actor.equipment[:torso] = armor_id

    defense_buff        = { source: 'Shield', on: :defense, value: 2, turns: 3 }
    @actor.active_buffs << defense_buff

    magic_defense_buff  = { source: 'Magic Barrier', on: :magic_defense, value: 2, turns: 3 }
    @actor.active_buffs << magic_defense_buff
 
    # Attacking :
    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack                  = { strength_damage:  2,
                                weapons:          [ :long_sword ],
                                weapon_damage:    14,
                                magic_weapons:    [],
                                magic_damage:     0,
                                ailments:         [] }
    attack_message[:attack] = attack
    response                = @actor.got_hit attack_message

    assert_equal  :got_hit, response[:type]
    assert_equal  @actor,   response[:parent]
    assert_nil              response[:target]

    hit = response[:got_hit]
    
    assert_equal  attack,                     hit[:hit_attack]
    assert_equal  armor[:value],              hit[:equipment_defense]         
    assert_equal  defense_buff[:value],       hit[:buff_defense]
    assert_equal  [ attack[:strength_damage]  +
                    attack[:weapon_damage]    -
                    armor[:value]             -
                    defense_buff[:value], 0 ].max,
                                              hit[:physical_damage]
    assert_equal  0,                          hit[:equipment_magic_defense]
    assert_equal  magic_defense_buff[:value], hit[:buff_magic_defense]
    assert_equal  [ attack[:magic_damage]         -
                    hit[:equipment_magic_defense] -
                    hit[:buff_magic_defense], 0 ].max,
                                              hit[:magic_damage]
    assert_empty                              hit[:ailments]
    assert_empty                              @actor.active_ailments
    assert_equal  hit[:physical_damage] +
                  hit[:magic_damage],
                                              hit[:total_damage]

    assert_equal  @actor.max_health - hit[:total_damage], @actor.health
  end

  it 'gets hit with magic weapons' do
    # Preping the actor :
    armor_id  = :leather_armor
    armor     = Combat::Equipment::PIECES[armor_id][:effects].first
    @actor.equipment[:torso] = armor_id

    helm_id   = :magic_helm
    helm      = Combat::Equipment::PIECES[helm_id][:effects].first
    @actor.equipment[:head] = helm_id

    defense_buff        = { source: 'Shield', on: :defense, value: 2, turns: 3 }
    @actor.active_buffs << defense_buff

    magic_defense_buff  = { source: 'Magic Barrier', on: :magic_defense, value: 2, turns: 3 }
    @actor.active_buffs << magic_defense_buff

    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack                  = { strength_damage:  2,
                                weapons:          [ :magic_sword ],
                                weapon_damage:    5,
                                magic_weapons:    [ :magic_sword ],
                                magic_damage:     5,
                                ailments:         [] }
    attack_message[:attack] = attack
    response                = @actor.got_hit attack_message

    assert_equal  :got_hit, response[:type]
    assert_equal  @actor,   response[:parent]
    assert_nil              response[:target]

    hit = response[:got_hit]
    
    assert_equal  attack,                       hit[:hit_attack]
    assert_equal  armor[:value] + helm[:value], hit[:equipment_defense] # leather armor + magic helm
    assert_equal  defense_buff[:value],         hit[:buff_defense]
    assert_equal  [ attack[:strength_damage]  +
                    attack[:weapon_damage]    -
                    hit[:equipment_defense]   -
                    hit[:buff_defense], 0 ].max,
                                                hit[:physical_damage]
    assert_equal  helm[:value],                 hit[:equipment_magic_defense]
    assert_equal  magic_defense_buff[:value],   hit[:buff_magic_defense]
    assert_equal  [ attack[:magic_damage]         -
                    hit[:equipment_magic_defense] -
                    hit[:buff_magic_defense], 0 ].max,
                                                hit[:magic_damage]
    assert_empty                                hit[:ailments]
    assert_empty                                @actor.active_ailments
    assert_equal  hit[:physical_damage] +
                  hit[:magic_damage],
                                                hit[:total_damage]

    assert_equal  @actor.max_health - hit[:total_damage], @actor.health
  end

  it 'gets hit with ailment weapons' do
    # Preping the actor :
    armor_id  = :leather_armor
    armor     = Combat::Equipment::PIECES[armor_id][:effects].first
    @actor.equipment[:torso] = armor_id

    helm_id   = :magic_helm
    helm      = Combat::Equipment::PIECES[helm_id][:effects].first
    @actor.equipment[:head] = helm_id

    defense_buff        = { source: 'Shield', on: :defense, value: 2, turns: 3 }
    @actor.active_buffs << defense_buff

    magic_defense_buff  = { source: 'Magic Barrier', on: :magic_defense, value: 2, turns: 3 }
    @actor.active_buffs << magic_defense_buff
 
    # Attacking :
    weapon_id               = :poisoned_dagger
    weapon_name             = Combat::Equipment.name weapon_id
    ailment_effect          = Combat::Equipment::PIECES[weapon_id][:effects].last 
    ailment                 = @actor.active_effect_from weapon_id, ailment_effect  
    attack_message          = Combat::Message.new_attack :a_parent, @actor
    attack                  = { strength_damage:  2,
                                weapons:          [ weapon_id ],
                                weapon_damage:    1,
                                magic_weapons:    [],
                                magic_damage:     0,
                                ailments:         [ { source: weapon_id, effect: ailment_effect } ] }
    attack_message[:attack] = attack
    response                = @actor.got_hit attack_message

    assert_equal  :got_hit, response[:type]
    assert_equal  @actor,   response[:parent]
    assert_nil              response[:target]

    hit = response[:got_hit]
    
    assert_equal  attack,                       hit[:hit_attack]
    assert_equal  armor[:value] + helm[:value], hit[:equipment_defense] # leather armor + magic helm
    assert_equal  defense_buff[:value],         hit[:buff_defense]
    assert_equal  [ attack[:strength_damage]  +
                    attack[:weapon_damage]    -
                    hit[:equipment_defense]   -
                    hit[:buff_defense], 0 ].max,
                                                hit[:physical_damage]
    assert_equal  helm[:value],                 hit[:equipment_magic_defense]
    assert_equal  magic_defense_buff[:value],   hit[:buff_magic_defense]
    assert_equal  [ attack[:magic_damage]         -
                    hit[:equipment_magic_defense] -
                    hit[:buff_magic_defense], 0 ].max,
                                                hit[:magic_damage]
    assert        same_effect?(ailment, hit[:ailments].first)
    assert        same_effect?(ailment, @actor.active_ailments.first)
    assert_equal  hit[:physical_damage] +
                  hit[:magic_damage],
                                                hit[:total_damage]

    assert_equal  @actor.max_health - hit[:total_damage], @actor.health
  end

  ### 6.2 Getting magic hit (or hit with magic, if you prefere) :
  it 'gets hit with magic attacks' do
    # Prep the actor to test equipment and buff influence on magic attack :
    helm_id   = :magic_helm
    helm      = Combat::Equipment::PIECES[helm_id][:effects].first
    @actor.equipment[:head] = helm_id

    magic_defense_buff  = { source: 'Magic Barrier', on: :magic_defense, value: 2, turns: 3 }
    @actor.active_buffs << magic_defense_buff

    # Attack :
    magic_attack_message                = Combat::Message.new_magic_attack :a_parent, [ @actor ]
    spell                               = Combat::Spell::SPELLS[:fire_ball]
    magic_attack                        = { magic_damage: 10,
                                            spell:        spell }
    magic_attack_message[:magic_attack] = magic_attack
    
    response  = @actor.got_magic_hit magic_attack_message

    assert_equal  :got_magic_hit, response[:type]
    assert_equal  @actor,         response[:parent]
    assert_nil                    response[:targets]

    hit = response[:got_magic_hit]

    assert_equal  helm[:value],                 hit[:equipment_magic_defense]
    assert_equal  magic_defense_buff[:value],   hit[:buff_magic_defense]
    assert_equal  [ magic_attack[:magic_damage]   -
                    hit[:equipment_magic_defense] -
                    hit[:buff_magic_defense], 0 ].max,
                                                hit[:magic_damage]
    assert_equal  spell,                        hit[:spell]
  end 

  ### 6.3 Heal :
  it 'heals' do
    hit_message           = Combat::Message.new_attack :a_parent, [ @actor ]
    hit_message[:attack]  = { strength_damage:  2,
                              weapons:          [ :long_sword ],
                              weapon_damage:    12,
                              magic_weapons:    [],
                              magic_damage:     0,
                              ailments:         [] }
    hit_response          = @actor.hit hit_message

    actor_health_before = @actor.health
    heal_amount         = 5
    heal_message        = Combat::Message.new_heal :another_parent, [ @actor ]
    heal_message[:heal] = { amount: heal_amount }
    response            = @actor.heal heal_message

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
    hit_response          = @actor.hit hit_message

    heal_amount         = strength_damage + weapon_damage + 1
    heal_message        = Combat::Message.new_heal :another_parent, [ @actor ]
    heal_message[:heal] = { amount: heal_amount }
    response            = @actor.heal heal_message

    assert_equal  :got_heal,  response[:type]
    assert_equal  @actor,     response[:parent]
    assert_nil                response[:targets]

    assert_equal  @actor.max_health,  @actor.health

    assert_equal  strength_damage + weapon_damage,  response[:got_heal][:amount]
    assert_equal  @actor.max_health,                response[:got_heal][:health]
  end

  ### 6.4 Add Mana :
  it 'restores mana' do
    
  end

  ### 6.5 Add Buff :
  it 'gets buffs' do
    buff_message            = Combat::Message.new_add_buff :a_parent, [ @actor ]
    spell                   = Combat::Spell::SPELLS[:raise_attack]
    buff                    = spell[:effects].first
    buff_message[:add_buff] = { name:   spell[:name],
                                on:     buff[:on],
                                value:  rand(buff[:value]),
                                turns:  buff[:turns] }
    response                = @actor.add_buff buff_message
     
    assert_includes @actor.active_buffs, buff_message[:add_buff]  

    assert_equal    :got_buff,  response[:type]
    assert_equal    @actor,     response[:parent]
    assert_nil                  response[:targets]

    assert_equal    buff_message[:add_buff],  response[:got_buff]
  end

  ### 6.6 Add Ailments :
  it 'gets ailments' do
    ailment_message               = Combat::Message.new_add_ailment :a_parent, [ @actor ]
    spell                         = Combat::Spell::SPELLS[:poison]
    ailment                       = spell[:effects].first
    ailment_message[:add_ailment] = { name:   spell[:name],
                                      on:     ailment[:on],
                                      value:  rand(ailment[:value]),
                                      turns:  ailment[:turns] }
    response                      = @actor.add_ailment ailment_message
     
    assert_includes @actor.active_ailments, ailment_message[:add_ailment]  

    assert_equal    :got_ailment, response[:type]
    assert_equal    @actor,       response[:parent]
    assert_nil                    response[:targets]

    assert_equal    ailment_message[:add_ailment],  response[:got_ailment]
  end

  ### 6.7 Receive :
  it 'receives items' do
    item                        = Combat::Item.new_health_potion
    give_message                = Combat::Message.new_give :a_parent, @actor
    give_message[:give][:gift]  = item
    give_message[:give][:stash] = :items
    receive_response            = @actor.receive give_message

    assert_equal  :received,  receive_response[:type]
    assert_equal  @actor,     receive_response[:parent]
    assert_nil                receive_response[:target]

    assert_equal  item,   receive_response[:received][:gift]
    assert_equal  :items, receive_response[:received][:stash]
  end

  it 'receives equipment' do
    equipment                   = :long_sword
    give_message                = Combat::Message.new_give :a_parent, @actor
    give_message[:give][:gift]  = equipment
    give_message[:give][:stash] = :equipment
    receive_response            = @actor.receive give_message

    assert_equal  :received,  receive_response[:type]
    assert_equal  @actor,     receive_response[:parent]
    assert_nil                receive_response[:target]

    assert_equal  equipment,  receive_response[:received][:gift]
    assert_equal  :equipment, receive_response[:received][:stash]
  end
end
