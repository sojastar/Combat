module Combat
  class Spell
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
    #add type ailment -> on health, mana, and what else ?
    SPELLS  = { fire_ball:            { name:         'Fire Ball',
                                        intelligence: 4,
                                        cost:         3,
                                        effects:      [ { type: :action, name: 'fire', on: :magic_attack, value: 3..5 } ] },
                heal:                 { name:         'Heal',
                                        intelligence: 2,
                                        cost:         3,
                                        effects:      [ { type: :action, name: 'heal', on: :heal, value: 7..12 } ] },
                poison:               { name:         'Poison',
                                        intelligence: 3,
                                        cost:         2,
                                        effects:      [ { type: :ailment, name: 'poison', on: :health, value: 1..3, turns: 3 } ] },
                raise_defense:        { name:         'Shield',
                                        intelligence: 3,
                                        cost:         2,
                                        effects:      [ { type: :buff, name: 'shield', on: :defense, value: 2..2, turns: 3 } ] },
                raise_magic_defense:  { name:         'Magic Barrier',
                                        intelligence: 4,
                                        cost:         2,
                                        effects:      [ { type: :buff, name: 'magic barrier', on: :magic_defense, value: 2..2, turns: 3 } ] },
                raise_attack:         { name:         'War Cry',
                                        intelligence: 3,
                                        cost:         2,
                                        effects:      [ { type: :buff, name: 'war cry', on: :attack, value: 2..3, turns: 3 } ] },
                raise_magic_attack:   { name:         'Secret Ritual',
                                        intelligence: 4,
                                        cost:         2,
                                        effects:      [ { type: :buff, name: 'secret ritual', on: :magic_attack, value: 2..4, turns: 3 } ] } }


    def self.name(spell)
      SPELLS[spell][:name]
    end

    def self.cost(spell)
      SPELLS[spell][:cost]
    end

    def self.can_cast?(intelligence,spell)
      intelligence >= SPELLS[spell][:intelligence]
    end

    def self.effects(spell)
      SPELLS[spell][:effects]
    end
    

    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_accessor :type,
                  :turns_left


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(type)
      @type = type
      @turns_left  = SPELLS[@type][:duration]
    end


    ############################################################################
    # 3. OTHER ACCESSORS :
    ############################################################################
    def name()                  SPELLS[@type][:name]          end
    def required_intelligence() SPELLS[@type][:intelligence]  end

    def defense_spell?
      SPELLS[@type][:effects].any? do |effect|
        effect[:category] == :buff && effect[:attribute] == :defense
      end
    end

    def defense
      SPELLS[@type][:effects].select { |effect|
        effect[:category] == :buff && effect[:attribute] == :defense
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end

    def magic_defense_spell?
      SPELLS[@type][:effects].any? do |effect|
        effect[:category] == :buff && effect[:attribute] == :magic_defense
      end
    end

    def magic_defense
      SPELLS[@type][:effects].select { |effect|
        effect[:category] == :buff && effect[:attribute] == :magic_defense
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end

    def attack_spell?
      SPELLS[@type][:effects].any? do |effect|
        effect[:category] == :buff && effect[:attribute] == :attack
      end
    end

    def attack
      SPELLS[@type][:effects].select { |effect|
        effect[:category] == :buff && effect[:attribute] == :attack
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end

    def magic_attack_spell?
      SPELLS[@type][:effects].any? do |effect|
        effect[:category] == :buff && effect[:attribute] == :magic_attack
      end
    end

    def magic_attack
      SPELLS[@type][:effects].select { |effect|
        effect[:category] == :buff && effect[:attribute] == :magic_attack
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end

    def can_cast(list, intelligence)
      list.filter { |spell| spell[:intelligence] <= intelligence }
    end


    ############################################################################
    # 4. TURNS :
    ############################################################################
    def fade()    @turns_left -= 1  end
    def faded?()  @turns_left <= 0  end
    alias done? faded?
  end
end

Combat::Spell::SPELLS.each_pair do |spell_type,spell|
  method_name = "new_#{spell_type.to_s}".to_sym
  Combat::Spell.define_singleton_method(method_name) { Combat::Spell.new spell_type }
end
