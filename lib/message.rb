module Combat
  module Message
    ############################################################################
    # 1. Empty :
    ############################################################################
    def self.new_empty
      { type:     :empty,
        parent:   nil,
        targets:  [],
        param:    nil,

        ### Actions :
        attack:       nil,
        magic_attack: nil,
        cast:         nil,
        use:          nil,
        equip:        nil,
        give:         nil,
        heal:         nil,
        add_mana:     nil,
        wait:         nil,

        ### Reactions :
        got_hit:        nil,
        got_magic_hit:  nil,
        got_heal:       nil,
        add_ailment:    nil,
        got_ailment:    nil,
        add_buff:       nil,
        got_buff:       nil,
        equiped:        nil,
        receive:        nil }
    end


    ############################################################################
    # 2. Manipulation :
    ############################################################################
    def self.retarget(message,new_target)
      message[:targets] = new_target
    end


    ############################################################################
    # 2. Action Messages :
    ############################################################################
    def self.new_attack(parent,targets)
      message = new_empty

      message[:type]    = :attack
      message[:parent]  = parent
      message[:targets] = targets
      message[:attack]  = { strength_damage:  0,
                            weapons:          [],
                            weapon_damage:    0,
                            magic_weapons:    [],
                            magic_damage:     0,
                            ailments:         [] }

      message
    end

    def self.new_magic_attack(parent,targets)
      message = new_empty

      message[:type]          = :magic_attack
      message[:parent]        = parent
      message[:targets]       = targets
      message[:magic_attack]  = { magic_damage: 0,
                                  ailments:     [],
                                  spell:        nil }

      message
    end

    def self.new_cast(parent,targets)
      message = new_empty

      message[:type]    = :cast
      message[:parent]  = parent
      message[:targets] = targets
      message[:cast]    = { spell:        nil,
                            submessages:  [] }

      message
    end

    def self.new_use(parent,targets)
      message  = new_empty

      message[:type]    = :use
      message[:parent]  = parent
      message[:targets] = targets
      message[:use]     = { item:         nil,
                            submessages:  [] }

      message
    end
      
    def self.new_equip(parent,targets)
      message  = new_empty

      message[:type]    = :equip
      message[:parent]  = parent
      message[:targets] = targets
      message[:equip]   = { equiment: nil }

      message
    end

    def self.new_give(parent,targets)
      message  = new_empty

      message[:type]    = :give
      message[:parent]  = parent
      message[:targets] = targets
      message[:give]    = { gift:   nil,
                            stash:  nil }

      message
    end

    def self.new_wait(parent,targets)
      message  = new_empty

      message[:parent]  = parent
      message[:type]   = x
      message[:targets]   = targets
      message[:x] = {}

      message
    end


    ############################################################################
    # 3. Reaction Messages :
    ############################################################################
    def self.new_got_hit(parent,targets)
      message = new_empty

      message[:type]      = :got_hit
      message[:parent]    = parent
      message[:targets]   = targets
      message[:got_hit]   = { equipment_defense:        [],
                              buff_defense:             0,
                              physical_damage:          0,
                              equipment_magic_defense:  [],
                              buff_magic_defense:       0,
                              magic_damage:             0,
                              ailments:                 [],
                              total_damage:             0 }

      message
    end

    def self.new_got_magic_hit(parent,targets)
      message = new_empty

      message[:type]          = :got_magic_hit
      message[:parent]        = parent
      message[:targets]       = targets
      message[:got_magic_hit] = { equipment_magic_defense:  [],
                                  buff_magic_defense:       0,
                                  magic_damage:             0,
                                  ailments:                 [],
                                  spell:                    nil }

      message
    end

    def self.new_heal(parent,targets)
      message = new_empty

      message[:type]    = :heal
      message[:parent]  = parent
      message[:targets] = targets
      message[:heal]    = { amount: 0, source: nil }

      message
    end

    def self.new_got_heal(parent,targets)
      message = new_empty

      message[:type]      = :got_heal
      message[:parent]    = parent
      message[:targets]   = targets
      message[:got_heal]  = { amount: 0, health: -1, source: nil }

      message
    end

    def self.new_add_mana(parent,targets)
      message  = new_empty

      message[:type]      = :add_mana
      message[:parent]    = parent
      message[:targets]   = targets
      message[:add_mana]  = { amount: 0, source: nil }

      message
    end

    def self.new_got_add_mana(parent,targets)
      message = new_empty

      message[:type]          = :got_add_mana
      message[:parent]        = parent
      message[:targets]       = targets
      message[:got_add_mana]  = { amount: 0, mana: -1, source: nil }

      message
    end

    def self.new_add_buff(parent,targets)
      message = new_empty

      message[:type]      = :add_buff
      message[:parent]    = parent
      message[:targets]   = targets
      message[:add_buff]  = { buff: nil }

      message
    end

    def self.new_got_buff(parent,targets)
      message = new_empty

      message[:type]      = :got_buff
      message[:parent]    = parent
      message[:targets]   = targets
      message[:got_buff]  = { buff: nil }

      message
    end

    def self.new_add_ailment(parent,targets)
      message = new_empty

      message[:type]        = :add_ailment
      message[:parent]      = parent
      message[:targets]     = targets
      message[:add_ailment] = { ailment: nil }

      message
    end

    def self.new_got_ailment(parent,targets)
      message = new_empty

      message[:type]        = :got_ailment
      message[:parent]      = parent
      message[:targets]     = targets
      message[:got_ailment] = { ailment: nil }

      message
    end

    def self.new_equiped(parent,targets)
      message = new_empty

      message[:type]    = :equiped
      message[:parent]  = parent
      message[:targets] = targets
      message[:equiped] = { equipment: nil }

      message
    end

    def self.new_receive(parent,targets)
      message = new_empty

      message[:type]    = x
      message[:parent]  = parent
      message[:targets]  = targets
      message[:x] = {}

      message
    end


    ############################################################################
    # 4. Menu Messages :
    ############################################################################
    def self.new_attack_selected(parent,menu_selection)
      message = new_empty

      message[:type]    = :attack_selected
      message[:parent]  = parent
      message[:targets] = menu_selection[:targets]

      message
    end

    def self.new_cast_selected(parent,menu_selection)
      message = new_empty

      message[:type]    = :cast_selected
      message[:parent]  = parent
      message[:targets] = menu_selection[:targets]
      message[:param]   = menu_selection[:param]

      message
    end

    def self.new_use_selected(parent,menu_selection)
      message = new_empty

      message[:type]    = :use_selected
      message[:parent]  = parent
      message[:targets] = menu_selection[:targets]
      message[:param]   = menu_selection[:param]

      message
    end

    def self.new_equip_selected(parent,menu_selection)
      message = new_empty

      message[:type]    = :equip_selected
      message[:parent]  = parent
      message[:targets] = menu_selection[:targets]
      message[:param]   = menu_selection[:param]

      message
    end

    def self.new_give_selected(parent,menu_selection)
      message = new_empty

      message[:type]    = :give_selected
      message[:parent]  = parent
      message[:targets] = menu_selection[:targets]
      message[:param]   = menu_selection[:param]

      message
    end
  end
end
