Module Combat
  class Monster
    MONSTERS  = { skeleton: { name:               "Skeleton",
                              health_point_range: 10..15,
                              armor:              0,
                              magic_armor:        1,
                              attacks:            [ { name:         "bone slash",
                                                      type:         :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.75 },
                                                    { name:         "smilling skull bite",
                                                      type:         :physical,
                                                      hits_range:   3..5,
                                                      probability:  0.25 } ] },
                  gobelin:  { name:               "Gobelin",
                              health_point_range: 6..10,
                              armor:              2,
                              magic_armor:        0,
                              attacks:            [ { name:         "sword slash",
                                                      type:         :physical,
                                                      hits_range:   2..3,
                                                      probability:  0.75 },
                                                    { name:         "power thrust",
                                                      type:         :physical,
                                                      hits_range:   4..7,
                                                      probability:  0.25 } ] },
                  warlock:  { name:               "Warlock",
                              health_point_range: 5..8,
                              armor:              1,
                              magic_armor:        3,
                              attacks:            [ { name:         "wand strike",
                                                      type:         :physical,
                                                      hits_range:   1..2,
                                                      probability:  0.45 },
                                                    { name:         "fire",
                                                      type:         :magical,
                                                      hits_range:   3..4,
                                                      probability:  0.35 },
                                                    { name:         "thunder",
                                                      type:         :magical,
                                                      hits_range:   5..7,
                                                      probability:  0.2 } ] } }

    attr_reader :type,
                :health_points

    def initialize(type)
      @type           = type
      @health_points  = rand(MONSTERS[:type][:health_point_range])
    end

    def armor
      MONSTERS[@type][:armor]
    end

    def magic_armor
      MONSTERS[@type][:magic_armor]
    end

    def attack(dice)
    end

    def self.new_skeleton(type) Combat::Monster.new :skeleton end
    def self.new_gobelin(type)  Combat::Monster.new :gobelin  end
    def self.new_warlock(type)  Combat::Monster.new :warlock  end
  end
end
