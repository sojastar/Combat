module Combat
  class Monster
    MONSTERS  = { skeleton: { name:               "Skeleton",
                              health_point_range: 10..15,
                              defense:            0,
                              magic_defense:      1,
                              initiative:         6,  
                              attacks:            [ { name:         "Bone Slash",
                                                      category:     :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.0...0.75 },
                                                    { name:         "smilling skull bite",
                                                      category:     :physical,
                                                      hits_range:   3..5,
                                                      probability:  0.75...1 } ],
                              loot:               { probability:  0.25,
                                                    items:        [ :leather_armor ] } },
                  gobelin:  { name:               "Gobelin",
                              health_point_range: 6..10,
                              defense:            2,
                              magic_defense:      0,
                              initiative:         5,  
                              attacks:            [ { name:         "Sword Slash",
                                                      category:     :physical,
                                                      hits_range:   2..3,
                                                      probability:  0.0...0.75 },
                                                    { name:         "Power thrust",
                                                      category:     :physical,
                                                      hits_range:   4..7,
                                                      probability:  0.75...1.0 } ],
                              loot:               { probability:  0.25,
                                                    items:        [ :long_sword,
                                                                    :health_potion ] } },
                  warlock:  { name:               "Warlock",
                              health_point_range: 5..8,
                              defense:            1,
                              magic_defense:      3,
                              initiative:         7,  
                              attacks:            [ { name:         "Wand Strike",
                                                      category:         :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.0...0.45 },
                                                    { name:         "Fire Ball",
                                                      category:     :magical,
                                                      hits_range:   3..4,
                                                      probability:  0.45...0.8 },
                                                    { name:         "Thunderbolt",
                                                      category:     :magical,
                                                      hits_range:   5..7,
                                                      probability:  0.8...1.0 } ],
                              loot:                 { probability:  0.25,
                                                      items:        [ :amulet,
                                                                      :mana_potion,
                                                                      :fire_wand ] } } }

    attr_reader :type,
                :health_points

    def initialize(type)
      @type           = type
      @health_points  = rand(MONSTERS[type][:health_point_range])
    end

    def name
      MONSTERS[@type][:name]
    end

    def initiative
      MONSTERS[@type][:initiative]
    end

    def defense
      MONSTERS[@type][:defense]
    end

    def magic_defense
      MONSTERS[@type][:magic_defense]
    end

    def attack(dice)
      attack  = MONSTERS[@type][:attacks].select { |attck| attck[:probability] === dice }.first
      damage  = rand(attack[:hits_range])

      { type:     "#{attack[:category].to_s}_attack".to_sym,
        actor:    :monster,
        damage:   damage,
        message:  "The #{MONSTERS[@type][:name]} hits you with a #{attack[:name]} that deals #{damage} hits." }
    end

    def drop(dice)
      loot_data = MONSTERS[@type][:loot]
      if dice <= loot_data[:probability]
        loot = loot_data[:items].sample

        { type:     :monster_drop,
          actor:    :monster,
          item:     loot,
          message:  "You search the #{MONSTERS[@type][:name]}'s dead body and find a #{Combat::Item::ITEMS[loot][:name]}." }

      else
        { type:     :monster_no_drop,
          actor:    :monster,
          message:  "You search the #{MONSTERS[@type][:name]}'s dead body but find nothing..." }

      end
    end
  end
end

Combat::Monster::MONSTERS.each_key do |monster_type|
  methode_name  = "new_#{monster_type.to_s}".to_sym
  Combat::Monster.define_singleton_method(methode_name) { Combat::Monster.new monster_type }
end
