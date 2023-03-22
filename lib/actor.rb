module Combat
  class Actor
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################

    # Nothing yet !


    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_reader :type,
                :name,
                :health, :max_health,
                :mana, :max_mana,
                :strength, :intelligence,
                :equipment, :equipment_stash,
                :items,
                :spells,
                :active_buffs, :active_ailments,
                :can_play


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(params)
      @type             = params[:type]
      @name             = params[:name] 

      @health           = params[:health]
      @max_health       = params[:health]

      @mana             = params[:mana]
      @max_mana         = params[:mana]

      @strength         = params[:strength]
      @intelligence     = params[:intelligence]

      @equipment        = params[:equipment]
      @equipment_stash  = []

      @items            = params[:items].map { |item_type| Combat::Item.new item_type }
      
      @spells           = params[:spells]
      
      @active_buffs     = []
      @active_ailments  = []

      @can_play         = true
    end


    ############################################################################
    # 4. OTHER ACCESSORS :
    ############################################################################
    def initiative() @strength + @intelligence end

    def alive?()  @health > 0   end
    def dead?()   @health <= 0  end


    ############################################################################
    # 5. EFFECTS, BUFFS and AILMENTS :
    ############################################################################
    def submessages_from_effects(source, effects, targets)
      effects.map do |effect|
        case effect[:type]
        when :action
          case effect[:on]
          when :attack
            submessage          = Message.new_attack self, targets
            submessage[:attack] = { strength_damage:  0,
                                    weapons:          [ source ],
                                    weapon_damage:    rand(effect[:value]),
                                    magic_weapons:    [],
                                    magic_damage:     0,
                                    ailments:         [] }

            submessage

          when :magic_attack
            submessage                = Message.new_magic_attack self, targets
            submessage[:magic_attack] = { magic_damage: rand(effect[:value]),
                                          ailments:     [],
                                          spell:        source }
            submessage

          when :heal
            submessage        = Message.new_heal self, targets
            submessage[:heal] = { amount: rand(effect[:value]),
                                  source: source }
            submessage

          when :add_mana
            submessage              = Message.new_add_mana self, targets
            submessage[:add_mana]   = { amount: rand(effect[:value]),
                                        source: source }
            submessage

          end

        when :buff
          submessage            = Message.new_add_buff self, targets
          #submessage[:add_buff] = active_effect_from source, effect
          submessage[:add_buff] = { source: source, effect: effect }
          submessage

        when :ailment
          submessage                = Message.new_add_ailment self, targets
          submessage[:add_ailment]  = { source: source, effect: effect }
          submessage
        end
      end
    end

    def active_effect_from(source, effect)
      { source: source,
        name:   effect[:name],
        on:     effect[:on], 
        value:  rand(effect[:value]),
        turns:  effect[:turns] }
    end

    def push_effect_to(effect,active_effects)
      same_on_effect  = active_effects.select { |active_effect|
                          effect[:on] == active_effect[:on]
                        }
                        .first  # should be only zero or one element

      if same_on_effect.nil?
        active_effects << effect
      else
        if effect[:value] >= same_on_effect[:value]
          same_on_effect[:value] = effect[:value]
          same_on_effect[:turns] = effect[:turns]
        end
      end
    end

    def resolve_ailements
      @active_ailments.each { |effect| resolve_ailement ailment }
    end

    def resolve_ailement(ailment)
      case ailment[:ailment]
      when :poison
        @health  -= rand(ailment[:value])
        @health   = 0 if @health < 0

      when :sleep
        @can_play = false

      end

      ### Update remaining turns :
      ailment[:turns] -= 1
    end


    ############################################################################
    # 6. TICK - RUN - UPDATE (whatever you fancy) :
    ############################################################################
    def update()
      @can_play = true # but maybe an ailment will change that...

      resolve_ailements

      # OVERRIDE BUT DON'T FORGET TO CALL super !
    end

    def castable_spells
      @spells.select { |spell|
        Spell.can_cast?(@intelligence, active_spell) &&
        Spell.cost(spell) <= @mana
      }
    end


    ############################################################################
    # 7. ACTIONS :
    ############################################################################

    ### 7.1 Attack :
    def attack(message)
      strength_damage   = rand(0..@strength)

      weapons       = @equipment.values.compact.select { |piece| Equipment.raise_attack? piece }
      weapon_damage = weapons.inject(0) { |damage,weapon|
        damage + Equipment.attack_value(weapon)
      }

      magic_weapons = @equipment.values.compact.select { |piece| Equipment.raise_magic_attack? piece }
      magic_damage  = magic_weapons.inject(0) { |damage,weapon|
        damage + Equipment.magic_attack_value(weapon)
      }

      ailments  =  @equipment.values.compact.select { |piece| Equipment.has_ailment_effect? piece }
                  .map { |piece| 
                    Equipment.ailment_effects(piece).map { |effect| { source: piece, effect: effect } }
                  } 
                  .flatten

      response            = Message.new_attack self, message[:targets]
      response[:attack]   = { strength_damage:  strength_damage,
                              weapons:          weapons,
                              weapon_damage:    weapon_damage,
                              magic_weapons:    magic_weapons,
                              magic_damage:     magic_damage,
                              ailments:         ailments }
      response
    end

    ### 7.2 Cast :
    def cast(message)
      spell         = message[:param]
      sub_messages  = submessages_from_effects  spell,
                                                Spell.effects(spell),
                                                message[:targets]

      response                      = Message.new_cast self, message[:targets]
      response[:cast][:spell]       = spell
      response[:cast][:submessages] = sub_messages
      response
    end

    ### 7.3 Use :
    def use(message)
      item          = message[:param]
      sub_messages  = submessages_from_effects  item.type,
                                                item.use,
                                                message[:targets]

      @items.delete(item) if item.depleted?

      response                      = Message.new_use self, message[:targets]
      response[:use][:item]         = item.type
      response[:use][:submessages]  = sub_messages
      response
    end

    ### 7.4 Equip :
    def equip(message)
      equipment = message[:param][:equipment]
      body_part = message[:param][:body_part]

      @equipment_stash << @equipment[:body_part] unless @equipment[body_part].nil?

      @equipment_stash.delete equipment
      @equipment[body_part] = equipment

      response                        = Message.new_equiped self, nil
      response[:equiped][:equipment]  = message[:param][:equipment]
      response
    end

    ### 7.5 Give :
    def give(message)
      gift  = message[:param][:gift]  
      stash = message[:param][:stash]

      case stash
      when :items     then @items.delete gift
      when :equipment then @equipment_stash.delete gift
      end

      response  = Message.new_give self, message[:targets]
      response[:give][:gift]  = gift
      response[:give][:stash] = stash
      response
    end
    alias drop give

    ### 7.6 Wait :
    def wait(message)
      Message.new_waited self, nil 
    end
    alias pass wait


    ############################################################################
    # 8. REACTIONS :
    ############################################################################

    ### 8.1 Get Hit :
    def got_hit(message)
      ### Convenience :
      attack = message[:attack]

      ### Physical damage :
      equipment_defense = @equipment.values.compact.filter { |piece|
                            Equipment.raise_defense? piece
                          }
                          .inject(0) { |defense,piece|
                            defense + Equipment.defense_value(piece)
                          }

      buff_defense  = @active_buffs.filter { |buff|
                        buff[:on] == :defense
                      }
                      .inject(0) { |defense,buff|
                        defense + buff[:value]
                      }

      physical_damage = [ 0, 
                          attack[:strength_damage]  + 
                          attack[:weapon_damage]    -
                          equipment_defense         -
                          buff_defense ].max

      ### Magic damage :
      equipment_magic_defense = @equipment.values.compact.filter { |piece|
                                  Equipment.raise_magic_defense? piece
                                }
                                .inject(0) { |defense,piece|
                                  defense + Equipment.magic_defense_value(piece)
                                }

      buff_magic_defense  = @active_buffs.filter { |buff|
                              buff[:on] == :magic_defense
                            }
                            .inject(0) { |defense,buff|
                              defense + buff[:value]
                            }

      magic_damage  = [ 0, 
                        attack[:magic_damage]   -
                        equipment_magic_defense -
                        buff_magic_defense ].max

      ### Ailments :
      new_ailments  = attack[:ailments].map do |ailment|
                        active_effect_from ailment[:source], ailment[:effect]
                      end

      new_ailments.each { |ailment| push_effect_to ailment, @active_ailments }

      ### Final damage calculation :
      total_damage  = physical_damage + magic_damage
      @health      -= total_damage
      @health       = 0 if @health < 0

      ### Message :
      response            = Message.new_got_hit self, nil 
      response[:got_hit]  = { hit_attack:               attack,
                              equipment_defense:        equipment_defense,
                              buff_defense:             buff_defense,
                              physical_damage:          physical_damage,
                              equipment_magic_defense:  equipment_magic_defense,
                              buff_magic_defense:       buff_magic_defense,
                              magic_damage:             magic_damage,
                              ailments:                 new_ailments,
                              total_damage:             total_damage }
      response
    end
    alias hit got_hit

    ### 8.2 Get Magic Hit :
    def got_magic_hit(message)
      ### Convenience :
      attack = message[:magic_attack]

      ### Magic damage :
      equipment_magic_defense = @equipment.values.compact.filter { |piece|
                                  Equipment.raise_magic_defense? piece
                                }
                                .inject(0) { |defense,piece|
                                  defense + Equipment.magic_defense_value(piece)
                                }

      buff_magic_defense  = @active_buffs.filter { |buff|
                              buff[:on] == :magic_defense
                            }
                            .inject(0) { |defense,buff|
                              defense + buff[:value]
                            }

      magic_damage  = [ 0, 
                        attack[:magic_damage]   -
                        equipment_magic_defense -
                        buff_magic_defense ].max

      ### Final damage calculation :
      @health  -= magic_damage
      @health   = 0 if @health < 0

      response                  = Message.new_got_magic_hit self, nil
      response[:got_magic_hit]  = { equipment_magic_defense:  equipment_magic_defense,
                                    buff_magic_defense:       buff_magic_defense,
                                    magic_damage:             magic_damage,
                                    spell:                    message[:magic_attack][:spell] }

      response
    end
    alias magic_hit got_magic_hit

    ### 8.3 Heal :
    def heal(message)
      amount  = message[:heal][:amount]

      if @health + amount <= @max_health
        @health    += amount
        heal_amount = amount
      else
        heal_amount = @max_health - @health
        @health     = @max_health
      end

      response            = Message.new_got_heal self, nil
      response[:got_heal] = { amount: heal_amount,
                              health: @health,
                              source: message[:heal][:source] }
      response
    end

    ### 8.4 Add Mana :
    def add_mana(message)
      amount  = message[:add_mana][:amount]

      if @mana + amount <= @max_mana
        @mana    += amount
        add_mana_amount = amount
      else
        add_mana_amount = @max_mana - @mana
        @mana           = @max_mana
      end

      response            = Message.new_got_add_mana self, nil
      response[:got_heal] = { amount: add_mana_amount,
                              mana:   @mana,
                              source: message[:add_mana][:source] }
      response
    end

    ### 8.5 Add Buff :
    def add_buff(message)
      new_buff  = active_effect_from  message[:add_buff][:source],
                                      message[:add_buff][:effect]
      push_effect_to new_buff, @active_buffs
      #push_effect_to message[:add_buff], @active_buffs

      response            = Message.new_got_buff self, nil
      response[:got_buff] = new_buff
      response
    end

    ### 8.6 Add Ailment :
    def add_ailment(message)
      new_ailment = active_effect_from  message[:add_ailment][:source],
                                        message[:add_ailment][:effect]
      push_effect_to new_ailment, @active_ailments

      response                = Message.new_got_ailment self, nil 
      response[:got_ailment]  = new_ailment
      response
    end

    ### 8.7 Receive :
    def receive(message)
      gift  = message[:give][:gift]  
      stash = message[:give][:stash]

      case stash
      when :items     then @items << gift
      when :equipment then @equipment_stash << gift
      end

      response  = Message.new_received self, nil
      response[:received][:gift]  = gift
      response[:received][:stash] = stash
      response
    end
  end
end
