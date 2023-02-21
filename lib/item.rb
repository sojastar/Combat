module Combat
  class Item
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
    ITEMS = { health_potion:  { name:     'Health Potion',
                                uses:     1,
                                effects:  [ { type: :action, on: :heal, value: 10 } ] },
              mana_potion:    { name:     'Mana Potion',
                                uses:     1,
                                effects:  [ { type: :action, on: :add_mana, value: 5 } ] },
              ambroisie:      { name:     'Ambroisie',
                                uses:     1,
                                effects:  [ { type: :action, on: :heal, value: 10 },
                                            { type: :action, on: :add_mana, value: 5 } ] },
              blowpipe:       { name:     'Blowpipe',
                                uses:     3,
                                effects:  [ { type: :action, on: :attack, value: 5..7 } ] },
              fire_wand:      { name:     'Fire Wand',
                                uses:     3,
                                effects:  [ { type: :action, on: :magic_attack, value: 5..10 } ] } }
    

    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_accessor :type, :uses


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(type)
      @type   = type
      @uses   = ITEMS[type][:uses]
    end


    ############################################################################
    # 3. OTHER ACCESSORS :
    ############################################################################
    def name()    ITEMS[@type][:name]     end
    def effects() ITEMS[@type][:effects]  end


    ############################################################################
    # 4. USAGE :
    ############################################################################
    def use() 
      unless depleted?
        @uses -= 1
        @effects

      else
        []

      end
    end

    def depleted?() @uses <= 0  end
    alias used? depleted?
  end
end

Combat::Item::ITEMS.each_pair do |item_type,item|
  method_name = "new_#{item_type.to_s}".to_sym
  Combat::Item.define_singleton_method(method_name) { Combat::Item.new item_type }
end
