module Combat
  class Spell
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
    SPELLS  = { fire_ball:    { name:     'Fire Ball',
                                cost:     3,
                                duration: 0,
                                effects:  [ { category: :magic_attack,
                                              hit_range: 4..6 } ] },
                heal:         { name:     'Heal',
                                cost:     2,
                                duration: 0,
                                effects:  [ { category:   :refill,
                                              attribute:  :health,
                                              value:      5..10 } ] },
                raise_defense:        { name:     'Shield',
                                        cost:     2,
                                        duration: 3,
                                        effects:  [ { category:   :buff,
                                                      attribute:  :defense,
                                                      value:      2 } ] },
                raise_magic_defense:  { name:     'Magic Barrier',
                                        cost:     2,
                                        duration: 3,
                                        effects:  [ { category:   :buff,
                                                      attribute:  :magic_defense,
                                                      value:      2 } ] },
                raise_attack:         { name:     'War Cry',
                                        cost:     2,
                                        duration: 3,
                                        effects:  [ { category:   :buff,
                                                      attribute:  :attack,
                                                      value:      2 } ] },
                raise_magic_attack:   { name:     'Secret Ritual',
                                        cost:     2,
                                        duration: 3,
                                        effects:  [ { category:   :buff,
                                                      attribute:  :magic_attack,
                                                      value:      2 } ] } }
    

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
    def name() SPELLS[@type][:name] end

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
