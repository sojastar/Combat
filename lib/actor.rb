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
      
      #@active_effects = []
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

    def resolve_ailements
      @active_effects.each do |effect|
      end
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
    # 6. RESPONSES :
    ############################################################################


    ############################################################################
    # 7. ACTIONS :
    ############################################################################

    ### 6.1 Attack :
    def attack(message)
      strength_damage   = rand(0..@strength)

      weapons       = @equipment.select { |piece| Equipment.has_attack_value? piece }
      weapon_damage = weapons.inject(0) { |damage,weapon|
        damage + Equipment.attack_value(weapon)
      }

      magic_weapons = @equipment.select { |piece| Equipment.has_magic_attack_value? piece }
      magic_damage  = magic_weapons.inject(0) { |damage,weapon|
        damage + Equipment.magic_attack_value(weapon)
      }

      ailments  =  @equipment.select { |piece| Equipment.has_ailment_effect? piece }
                             .map { |piece| Equipment.ailment_effects piece }
                             .flatten

      message           = Message.new_attack self, message[:targets]
      message[:attack]  = { strength_damage:  strength_damage,
                            weapons:          weapons,
                            weapon_damage:    weapon_damage,
                            magic_weapons:    magic_weapons,
                            magic_damage:     magic_damage,
                            ailments:         ailments }
      message
    end

    ### 6.2 Cast :
    def cast(message)
      spell = message[:param]
      Spell.effects(spell).map do |effect|
        case effect[:type]
        when :action
          case effect[:on]
          when :magic_attack
            Message.new_magic_attack self, message[:targets]
            message[:magic_attack]  = { magic_damage: rand(effect[:value]),
                                        spell:        spell }

          when :ailment
            Message.new_add_ailment self, message[:targets]
            message[:add_ailment] = { ailment: nil } # FOR NOW !!!

          when :heal
            Message.new_heal self, message[:targets]
            message[:heal]  = { amount: rand(effect[:value]) }
          end

        when :buff
            Message.new_buff self, message[:targets]
            message[:add_buff]  = { type:   effect[:type],
                                    on:     effect[:on], 
                                    value:  rand(effect[:value]),
                                    turns:  effect[:turns] }
        end
      end
    end

    ### 6.3 Use :
    def use(item)
    end

    ### 6.4 Equip :
    def equip(item)
      
    end

    ### 6.5 Give :
    def give(item)
      
    end
    alias drop give

    ### 6.8 Wait :
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

      #buff_defense  = @active_effects.filter { |effect|
      buff_defense  = @active_buffs.filter { |effect|
                       effect[:on] == :defense
                      }
                      .inject(0) { |defense,effect|
                        defense + rand(effect[:value])
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

      #buff_magic_defense  = @active_effects.filter { |effect|
      buff_magic_defense  = @active_buffs.filter { |effect|
                              effect[:on] == :magic_defense
                            }
                            .inject(0) { |defense,effect|
                              defense + rand(effect[:value])
                            }

      magic_damage  = [ 0, 
                        attack[:magic_damage]   -
                        equipment_magic_defense -
                        buff_magic_defense ].max

      ### Ailments :
      new_ailments  = attack[:ailments].map { |ailment| ailment.dup }
      #new_ailments.each { |ailment| resolve_effect ailment }
      new_ailments.each { |ailment| @active_ailments << ailment }

      #@active_effects += new_ailments
      #@active_ailments += new_ailments

      ### Final damage calculation :
      total_damage  = physical_damage + magic_damage
      @health      -= total_damage

      message           = Message.new_got_hit self, nil 
      message[:got_hit] = { hit_attack:               attack,
                            equipment_defense:        equipment_defense,
                            buff_defense:             buff_defense,
                            physical_damage:          physical_damage,
                            equipment_magic_defense:  equipment_magic_defense,
                            buff_magic_defense:       buff_magic_defense,
                            magic_damage:             magic_damage,
                            ailments:                 new_ailments,
                            total_damage:             total_damage }
      message
    end
    alias hit got_hit

    ### 8.2 Get Magic Hit :
    def get_magic_hit(message)
      message = Message.new_get_magic_hit self, [ self ]
    end

    ### 8.4 Heal :
    def heal(message)
      amount  = message[:heal][:amount]

      if @health + amount <= @max_health
        @health    += amount
        heal_amount = amount
      else
        heal_amount = @max_health - @health
        @health     = @max_health
      end

      message             = Message.new_got_heal self, nil
      message[:got_heal]  = { amount: heal_amount,
                              health: @health }
      message
    end

    ### 8.5 Add Buff :
    def buff(effect)
      @active_buffs << message[:add_buff][:buff]

      message             = Message.new_got_buff self, nil
      message[:got_buff]  = { buff: message[:add_buff][:buff] }
      message
    end

    ### 8.3 Add Ailment :
    def add_ailment(message)
      @active_ailments << ailment = message[:add_ailment][:ailment]

      message               = Message.new_got_ailment self, nil 
      message[:got_ailment] = { ailment: message[:add_ailment][:ailment] }
      message
    end

    ### 8.7 Add Mana :
    def add_mana(message)
    end

    def receive(item)
    end
  end
end
