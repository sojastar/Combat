module Combat
  class Monster
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
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
                                                      category:     :magic,
                                                      hits_range:   3..4,
                                                      probability:  0.45...0.8 },
                                                    { name:         "Thunderbolt",
                                                      category:     :magic,
                                                      hits_range:   5..7,
                                                      probability:  0.8...1.0 } ],
                              loot:                 { probability:  0.25,
                                                      items:        [ :amulet,
                                                                      :mana_potion,
                                                                      :fire_wand ] } } }
    

    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_reader :type,
                :health


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(type)
      @type   = type
      @health = rand(MONSTERS[type][:health_point_range])
    end

    def self.new_random_monster
      monster_types = MONSTERS.keys
      Monster.new monster_types.sample
    end


    ############################################################################
    # 4. OTHER ACCESSORS :
    ############################################################################
    def name()          MONSTERS[@type][:name]          end
    def initiative()    MONSTERS[@type][:initiative]    end
    def defense()       MONSTERS[@type][:defense]       end
    def magic_defense() MONSTERS[@type][:magic_defense] end

    def alive?()  @health > 0   end
    def dead?()   @health <= 0  end


    ############################################################################
    # 5. ACTIONS :
    ############################################################################
    def attack(dice)
      attack  = MONSTERS[@type][:attacks].select { |attck| attck[:probability] === dice }.first
      damage  = rand(attack[:hits_range])

      { type:     "#{attack[:category].to_s}_attack".to_sym,
        actor:    :monster,
        damage:   damage,
        message:  "The #{MONSTERS[@type][:name]} hits you with a #{attack[:name]} that deals #{damage} hits." }
    end


    ############################################################################
    # 6. REACTIONS :
    ############################################################################
    def hit(attack)
      result  = case attack[:type]
                when :physical_attack
                  if defense > 0
                    if defense >= attack[:damage]
                      { damage:   0,
                        message:  "The #{name}'s armor blocks all your damage..." }

                    else
                      damage  = attack[:damage] - defense
                      message = "The #{name}'s armor blocks #{defense} damage. "\
                                "You inflict #{damage} damage."
                      { damage: damage, message: message }

                    end

                  else"You get hit for #{damage} damage." 
                    { damage: attack[:damage],
                      message:  "You inflict #{attack[:damage]} damage to the #{name}." }

                  end

                when :magic_attack
                  if magic_defense > 0
                    if magic_defense >= attack[:damage]
                      { damage:   0,
                        message:  "The #{name}'s magic armor blocks all your damage..." }

                    else
                      damage  = attack[:damage] - magic_defense
                      message = "The #{name}'s magic armor blocks #{magic_defense} damage. "\
                                "You inflict #{damage} magic damage."
                      { damage: damage, message: message }

                    end

                  else
                    { damage:   attack[:damage],
                      message:  "You inflict #{attack[:damage]} magic damage to the #{name}." }

                  end

                end

      @health -= result[:damage]

      { type:     :monster_get_hit,
        actor:    :monster,
        message:  result[:message] }
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
