module Combat
  module Equipment
    def self.name(piece)
      PIECES[piece][:name]
    end

    def self.attach_to(piece)
      PIECES[piece][:body_part]
    end

    def self.raise_attack?(piece)
      PIECES[piece][:effects].any? do |effect|
        effect[:on] == :attack
      end
    end

    def self.attack_value(piece)
      PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :attack ? effect[:value] : 0 )
      end
    end

    def self.raise_magic_attack?(piece)
      PIECES[piece][:effects].any? do |effect|
        effect[:on] == :magic_attack
      end
    end

    def self.magic_attack_value(piece)
      PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :magic_attack ? effect[:value] : 0 )
      end
    end

    def self.has_ailment_effect?(piece)
      PIECES[piece][:effects].any? do |effect|
        effect[:type] == :ailment 
      end
    end

    def self.ailment_effects(piece)
      PIECES[piece][:effects].select do |effect|
        effect[:type] == :ailment
      end
    end

    def self.raise_defense?(piece)
      PIECES[piece][:effects].any? do |effect|
        effect[:on] == :defense
      end
    end

    def self.defense_value(piece)
      PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :defense ? effect[:value] : 0 )
      end
    end

    def self.raise_magic_defense?(piece)
      PIECES[piece][:effects].any? do |effect|
        effect[:on] == :magic_defense
      end
    end

    def self.magic_defense_value(piece)
      PIECES[piece][:effects].inject(0) do |buff,effect|
        buff + ( effect[:on] == :magic_defense ? effect[:value] : 0 )
      end
    end
  end
end
