module Combat
  module Spell
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
                toxic_sleep:          { name:         'Poison',
                                        intelligence: 3,
                                        cost:         2,
                                        effects:      [ { type: :ailment, name: 'sleep', on: :sleep, value: 0..0, turns: 3 },
                                                        { type: :ailment, name: 'poison', on: :health, value: 1..3, turns: 3 } ] },
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
  end
end
