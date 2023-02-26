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
                :equipment,
                :items,
                :spells,# :active_effects,
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
    def active_effect_from(source_name, effect)
      { source: source_name,
        on:     effect[:on], 
        value:  rand(effect[:value]),
        turns:  effect[:turns] }
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

      weapons       = @equipment.select { |piece| Equipment.raise_attack? piece }
      weapon_damage = weapons.inject(0) { |damage,weapon|
        damage + Equipment.attack_value(weapon)
      }

      magic_weapons = @equipment.select { |piece| Equipment.raise_magic_attack? piece }
      magic_damage  = magic_weapons.inject(0) { |damage,weapon|
        damage + Equipment.magic_attack_value(weapon)
      }

      ailments  =  @equipment.select { |piece| Equipment.has_ailment_effect? piece }
                             .map { |piece| Equipment.ailment_effects piece }
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
      spell = message[:param]

      sub_messages  = Spell.effects(spell).map do |effect|
                        case effect[:type]
                        when :action
                          case effect[:on]
                          when :magic_attack
                            Message.new_magic_attack self, message[:targets]
                            message[:magic_attack]  = { magic_damage: rand(effect[:value]),
                                                        spell:        spell }

                          when :heal
                            Message.new_heal self, message[:targets]
                            message[:heal]  = { amount: rand(effect[:value]) }
                          end

                        when :buff
                          Message.new_add_buff self, message[:targets]
                          message[:add_buff]  = active_effect_from  spell[:name],
                                                                    effect

                        when :ailment
                          Message.new_add_ailment self, message[:targets]
                          message[:add_buff]  = active_effect_from  spell[:name],
                                                                    effect
                        end


                      end

      response                      = Combat.new_cast self, message[:targets]
      response[:cast][:submessages] = sub_messages
      response
    end

    ### 7.3 Use :
    def use(item)
    end

    ### 7.4 Equip :
    def equip(item)
      
    end

    ### 7.5 Give :
    def give(item)
      
    end
    alias drop give

    ### 7.8 Wait :
    def wait
      
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
      equipment_defense = @equipment.filter { |piece|
                            Equipment.has_defense_value? piece
                          }
                          .inject(0) { |defense,piece|
                            defense + Equipment.defense_value(piece)
                          }

      buff_defense  = @active_buffs.filter { |buff|
                       buff[:on] == :defense
                      }
                      .inject(0) { |defense,buff|
                        defense + rand(buff[:value])
                      }

      physical_damage = [ 0, 
                          attack[:strength_damage]  + 
                          attack[:weapon_damage]    -
                          equipment_defense         -
                          buff_defense ].max

      ### Magic damage :
      equipment_magic_defense = @equipment.filter { |piece|
                                  Equipment.has_magic_defense_value? piece
                                }
                                .inject(0) { |defense,piece|
                                  defense + Equipment.magic_defense_value(piece)
                                }

      buff_magic_defense  = @active_buffs.filter { |buff|
                              buff[:on] == :magic_defense
                            }
                            .inject(0) { |defense,buff|
                              defense + rand(buff[:value])
                            }

      magic_damage  = [ 0, 
                        attack[:magic_damage]   -
                        equipment_magic_defense -
                        buff_magic_defense ].max

      ### Ailments :
      new_ailments  = attack[:ailments].map { |ailment| ailment.dup }
      new_ailments.each { |ailment| @active_ailments << ailment }

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
      ### Magic damage :
      equipment_magic_defense = @equipment.filter { |piece|
                                  Equipment.has_magic_defense_value? piece
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
                        message[:magic_attack][:magic_damage]   -
                        equipment_magic_defense -
                        buff_magic_defense ].max

      ### Ailments :
      new_ailments  = message[:magic_attack][:ailments].map { |ailment| ailment.dup }
      new_ailments.each { |ailment| @active_ailments << ailment }

      ### Final damage calculation :
      @health  -= magic_damage
      @health   = 0 if @health < 0

      response                  = Message.new_got_magic_hit self, nil
      response[:got_magic_hit]  = { equipment_magic_defense:  equipment_magic_defense,
                                    buff_magic_defense:       buff_magic_defense,
                                    magic_damage:             magic_damage,
                                    ailments:                 new_ailments,
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
                              health: @health }
      response
    end

    ### 8.4 Add Buff :
    def add_buff(message)
      @active_buffs << message[:add_buff]

      response            = Message.new_got_buff self, nil
      response[:got_buff] = message[:add_buff]
      response
    end

    ### 8.5 Add Ailment :
    def add_ailment(message)
      @active_ailments << ailment = message[:add_ailment]

      response                = Message.new_got_ailment self, nil 
      response[:got_ailment]  = message[:add_ailment]
      response
    end

    ### 8.6 Add Mana :
    def add_mana(message)
    end

    def receive(item)
    end
  end
end
