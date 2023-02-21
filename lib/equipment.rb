module Combat
  module Equipment
    PIECES  = { long_sword:       { name:       "Long Sword",
                                    effects:    [ { type: :action, on: :attack, value: 2 } ] },
                poisoned_dagger:  { name:       "Poisoned Dagger",
                                    effects:    [ { type: :action, on: :attack, value: 1 },
                                                  { type: :action, on: :ailment, ailment: :poison, value: 1..3, turns: 3 } ] },
                magic_sword:      { name:       "Magic Sword",
                                    effects:    [ { type: :action, on: :attack, value: 1 },
                                                  { type: :action, on: :magic_attack, value: 1 } ] },
                leather_armor:    { name:       'Leather Armor',
                                    effects:    [ { type: :buff, on: :defense, value: 2 } ] },
                amulet:           { name:       'Amulet',
                                    effects:    [ { type: :buff, on: :magic_defense, value: 2 } ] },
                magic_helm:       { name:       'Magic Helm',
                                    effects:    [ { type: :buff, on: :defense, value: 1 },
                                                  { type: :buff, on: :magic_defense, value: 1 } ] } }

    def self.has_attack_value?(piece)
      Combat::Equipment::PIECES[piece][:effects].any? do |effect|
        effect[:on] == :attack
      end
    end

    def self.attack_value(piece)
      Combat::Equipment::PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :attack ? effect[:value] : 0 )
      end
    end

    def self.has_magic_attack_value?(piece)
      Combat::Equipment::PIECES[piece][:effects].any? do |effect|
        effect[:on] == :magic_attack
      end
    end

    def self.magic_attack_value(piece)
      Combat::Equipment::PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :magic_attack ? effect[:value] : 0 )
      end
    end

    def self.has_ailment_effect?(piece)
      Combat::Equipment::PIECES[piece][:effects].any? do |effect|
        effect[:on] == :ailment 
      end
    end

    def self.ailment_effects(piece)
      Combat::Equipment::PIECES[piece][:effects].select do |effect|
        effect[:on] == :ailment
      end
    end

    def self.has_defense_value?(piece)
      Combat::Equipment::PIECES[piece][:effects].any? do |effect|
        effect[:on] == :defense
      end
    end

    def self.defense_value(piece)
      Combat::Equipment::PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :defense ? effect[:value] : 0 )
      end
    end

    def self.has_magic_defense_value?(piece)
      Combat::Equipment::PIECES[piece][:effects].any? do |effect|
        effect[:on] == :magic_defense
      end
    end

    def self.magic_defense_value(piece)
      Combat::Equipment::PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :magic_defense ? effect[:value] : 0 )
      end
    end
  end
end
