module Combat
  class Item
    ITEMS = { long_sword:     { name:     "Long Sword",
                                type:     :equipment,
                                effects:  [ { type: :modifier, attribute: :strength, value: 2 } ] },
              leather_armor:  { name:     'Leather Armor',
                                type:     :equipment,
                                effects:  [ { type: :modifier, attribute: :defense, value: 2 } ] },
              amulet:         { name:     'Amulet',
                                type:     :equipment,
                                effects:  [ { type: :modifier, attribute: :magic_defense, value: 2 } ] },
              health_potion:  { name:     'Health Potion',
                                type:     :consumable,
                                uses:     1,
                                effects:  [ { type: :modifier, attribute: :health, value: 10 } ] },
              mana_potion:    { name:     'Mana Potion',
                                type:     :consumable,
                                uses:     1,
                                effect:   [ { type: :modifier, attribute: :mana, value: 5 } ] },
              fire_wand:      { name:     'Fire Wand',
                                type:     :consumable,
                                uses:     3,
                                effects:  [ { type: :attack, value: 5..10 } ] }  }
    # other possible items: magic sword, magic armor, health and mana potion, ...
    # ... all sorts of wands, etc...
    
    def initialize(type)
    end
  end
end
