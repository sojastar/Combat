module Combat
  module Spell
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
