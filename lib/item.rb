module Combat
  class Item
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
    ITEMS = { long_sword:     { name:     "Long Sword",
                                category: :equipment,
                                effects:  [ { category: :modifier, attribute: :strength, value: 2 } ] },
              leather_armor:  { name:     'Leather Armor',
                                category: :equipment,
                                effects:  [ { category: :modifier, attribute: :defense, value: 2 } ] },
              amulet:         { name:     'Amulet',
                                category: :equipment,
                                effects:  [ { category: :modifier, attribute: :magic_defense, value: 2 } ] },
              magic_helm:     { name:     'Magic Helm',
                                category: :equipment,
                                effects:  [ { category: :modifier, attribute: :defense, value: 1 },
                                            { category: :modifier, attribute: :magic_defense, value: 1 } ] },
              health_potion:  { name:     'Health Potion',
                                category: :consumable,
                                uses:     1,
                                effects:  [ { category: :modifier, attribute: :health, value: 10 } ] },
              mana_potion:    { name:     'Mana Potion',
                                category: :consumable,
                                uses:     1,
                                effects:  [ { category: :modifier, attribute: :mana, value: 5 } ] },
              blowpipe:       { name:     'Blowpipe',
                                category: :consumable,
                                uses:     3,
                                effects:  [ { category: :attack, hits_range: 5..7 } ] },
              fire_wand:      { name:     'Fire Wand',
                                category: :consumable,
                                uses:     3,
                                effects:  [ { category: :magic_attack, hits_range: 5..10 } ] } }
    # other possible items: magic sword, magic armor, health and mana potion, ...
    # ... all sorts of wands, etc...
    

    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_accessor :type,
                  :usable, :uses


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(item_type)
      @type   = item_type

      if ITEMS[item_type][:category] == :consumable
        @usable = true
        @uses   = ITEMS[item_type][:uses]
      else
        @usable = false
      end
    end


    ############################################################################
    # 3. OTHER ACCESSORS :
    ############################################################################
    def name() ITEMS[@type][:name] end

    def defense_item?
      ITEMS[@type][:effects].any? do |effect|
        effect[:category] == :modifier && effect[:attribute] == :defense
      end
    end

    def defense
      ITEMS[@type][:effects].select { |effect|
        effect[:category] == :modifier && effect[:attribute] == :defense
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end

    def magic_defense_item?
      ITEMS[@type][:effects].any? do |effect|
        effect[:category] == :modifier && effect[:attribute] == :magic_defense
      end
    end

    def magic_defense
      ITEMS[@type][:effects].select { |effect|
        effect[:category] == :modifier && effect[:attribute] == :magic_defense
      }
      .inject(0) { |total,effect|
        total + effect[:value]
      }
    end


    ############################################################################
    # 4. USAGE :
    ############################################################################
    def usable?() @usable end

    def self.usable(list)
      list.filter { |item| item.usable? }
    end

    def use() 
      if @usable
        @uses -= 1
      else
        raise "Item #{@type} is not usable!"
      end
    end

    def depleted?()
      if @usable
        @uses <= 0
      else 
        raise "Item #{@type} is not usable so cannot be depleted!"
      end
    end
    alias used? depleted?
  end
end

Combat::Item::ITEMS.each_pair do |item_type,item|
  method_name = "new_#{item_type.to_s}".to_sym
  Combat::Item.define_singleton_method(method_name) { Combat::Item.new item_type }
end
