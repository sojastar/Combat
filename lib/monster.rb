module Combat
  class Monster
    MONSTERS  = { skeleton: { name:               "Skeleton",
                              health_point_range: 10..15,
                              defense:            0,
                              magic_defense:      1,
                              attacks:            [ { name:         "bone slash",
                                                      type:         :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.0...0.75 },
                                                    { name:         "smilling skull bite",
                                                      type:         :physical,
                                                      hits_range:   3..5,
                                                      probability:  0.75...1 } ] },
                  gobelin:  { name:               "Gobelin",
                              health_point_range: 6..10,
                              defense:            2,
                              magic_defense:      0,
                              attacks:            [ { name:         "sword slash",
                                                      type:         :physical,
                                                      hits_range:   2..3,
                                                      probability:  0.0...0.75 },
                                                    { name:         "power thrust",
                                                      type:         :physical,
                                                      hits_range:   4..7,
                                                      probability:  0.75...1.0 } ] },
                  warlock:  { name:               "Warlock",
                              health_point_range: 5..8,
                              defense:            1,
                              magic_defense:      3,
                              attacks:            [ { name:         "wand strike",
                                                      type:         :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.0...0.45 },
                                                    { name:         "fire",
                                                      type:         :magical,
                                                      hits_range:   3..4,
                                                      probability:  0.45...0.8 },
                                                    { name:         "thunder",
                                                      type:         :magical,
                                                      hits_range:   5..7,
                                                      probability:  0.8...1.0 } ] } }

    attr_reader :type,
                :health_points

    def initialize(type)
      @type           = type
      @health_points  = rand(MONSTERS[type][:health_point_range])
    end

    def name
      MONSTERS[@type][:name]
    end

    def defense
      MONSTERS[@type][:defense]
    end

    def magic_defense
      MONSTERS[@type][:magic_defense]
    end

    def attack(dice)
      attack  = MONSTERS[@type][:attacks].select { |attck| attck[:probability] === dice }.first

      { name: attack[:name],
        type: attack[:type],
        hits: rand(attack[:hits_range]) }
    end

    def self.new_skeleton() Combat::Monster.new :skeleton end
    def self.new_gobelin()  Combat::Monster.new :gobelin  end
    def self.new_warlock()  Combat::Monster.new :warlock  end
  end
end
