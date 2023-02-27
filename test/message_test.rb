require 'minitest/autorun'
require_relative 'test_helper.rb'

describe Combat::Message do
  it 'can create an empty reponse hash' do
    message = Combat::Message.new_empty

    assert_equal  :empty, message[:type]
    assert_nil            message[:parent]
    assert_equal  [],     message[:targets]
    assert_nil            message[:param]

    assert_nil    message[:attack]
    assert_nil    message[:magic_attack]
    assert_nil    message[:cast]
    assert_nil    message[:use]
    assert_nil    message[:equip]
    assert_nil    message[:give]
    assert_nil    message[:heal]
    assert_nil    message[:add_mana]
    assert_nil    message[:wait]
    assert_nil    message[:got_hit]
    assert_nil    message[:got_magic_hit]
    assert_nil    message[:got_heal]
    assert_nil    message[:add_ailment]
    assert_nil    message[:add_buff]
    assert_nil    message[:receive]
  end

  it 'can have its target changed' do
    message = Combat::Message.new_attack :a_parent, :some_targets
    Combat::Message.retarget message, :new_targets

    assert_equal  :new_targets, message[:targets]
  end

  it 'can create an empty attack message' do
    message = Combat::Message.new_attack :a_parent, :some_targets

    assert_equal  :attack,        message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_equal  0,  message[:attack][:strength_damage]
    assert_equal [],  message[:attack][:weapons]        
    assert_equal  0,  message[:attack][:weapon_damage]  
    assert_equal [],  message[:attack][:magic_weapons]  
    assert_equal  0,  message[:attack][:magic_damage]   
    assert_equal [],  message[:attack][:ailments]       
  end

  it 'can create an empty magic attack message' do
    message = Combat::Message.new_magic_attack :a_parent, :some_targets

    assert_equal  :magic_attack,  message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_nil                    message[:magic_attack][:spell]
    assert_equal  0,              message[:magic_attack][:magic_damage]        
  end

  it 'can create an empty cast message' do
    #message  = Combat::Message.new_cast :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty use message' do
    #message  = Combat::Message.new_use :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty equip message' do
    #message  = Combat::Message.new_equip :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty give message' do
    #message  = Combat::Message.new_give :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty heal message' do
    message = Combat::Message.new_heal :a_parent, :some_targets

    assert_equal  :heal,          message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_equal   0, message[:heal][:amount]
    #assert_equal  -1, message[:heal][:health]
  end

  it 'can create an empty add_mana message' do
    #message  = Combat::Message.new_add_mana :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty wait message' do
    #message  = Combat::Message.new_wait :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it 'can create an empty got_hit message' do
    message = Combat::Message.new_got_hit :a_parent, :some_targets

    assert_equal  :got_hit,       message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_equal [],  message[:got_hit][:equipment_defense]
    assert_equal  0,  message[:got_hit][:buff_defense]
    assert_equal  0,  message[:got_hit][:physical_damage]
    assert_equal [],  message[:got_hit][:equipment_magic_defense]
    assert_equal  0,  message[:got_hit][:buff_magic_defense]
    assert_equal  0,  message[:got_hit][:magic_damage]
    assert_equal [],  message[:got_hit][:ailments]
    assert_equal  0,  message[:got_hit][:total_damage]
  end

  it 'can create an empty got_magic_hit message' do
    message = Combat::Message.new_got_magic_hit :a_parent, :some_targets

    assert_equal  :got_magic_hit, message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_equal  0,  message[:got_magic_hit][:buff_magic_defense]
    assert_equal  0,  message[:got_magic_hit][:magic_damage]
    assert_equal [],  message[:got_magic_hit][:ailments]
    assert_nil        message[:got_magic_hit][:spell]
  end

  it 'can create an empty get heal message' do
    message = Combat::Message.new_got_heal :a_parent, :some_targets

    assert_equal  :got_heal,      message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_equal   0, message[:got_heal][:amount]
    assert_equal  -1, message[:got_heal][:health]
  end

  it 'can create an empty add buff message' do
    message = Combat::Message.new_add_buff :a_parent, :some_targets

    assert_equal  :add_buff,      message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_nil  message[:add_buff][:buff]
  end

  it 'can create an empty got buff message' do
    message = Combat::Message.new_got_buff :a_parent, :some_targets

    assert_equal  :got_buff,      message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_nil  message[:got_buff][:buff]
  end

  it 'can create an empty add ailment message' do
    message = Combat::Message.new_add_ailment :a_parent, :some_targets

    assert_equal  :add_ailment,   message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_nil  message[:add_ailment][:ailment]
  end

  it 'can create an empty got ailment message' do
    message = Combat::Message.new_got_ailment :a_parent, :some_targets

    assert_equal  :got_ailment,   message[:type]           
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]

    assert_nil  message[:got_ailment][:ailment]
  end

  it 'can create a receive message' do
    #message  = Combat::Message.new_receive :some_targets

    #assert_equal  x,  message[:type]

    #assert_equal  y, message[:x][:z]
  end

  it "can create an 'attack_selected' message" do
    message = Combat::Message.new_attack_selected(  :a_parent,
                                                    { targets:  :some_targets,
                                                      param:    nil } )

    assert_equal  :attack_selected, message[:type]
    assert_equal  :a_parent,        message[:parent]
    assert_equal  :some_targets,    message[:targets]
    assert_nil                      message[:param]
  end

  it "can create an 'cast_selected' message" do
    message = Combat::Message.new_cast_selected( :a_parent,
                                                  { targets:  :some_targets,
                                                    param:    :a_spell } )

    assert_equal  :cast_selected, message[:type]
    assert_equal  :a_parent,      message[:parent]
    assert_equal  :some_targets,  message[:targets]
    assert_equal  :a_spell,       message[:param] 
  end
end