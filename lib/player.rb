module Combat
  class Player
    attr_reader :health, :max_health,
                :mana, :max_mana,
                :strength,
                :intelligence,
                :defense, :magic_defense,
                :items

    def initialize(health,mana,strength,intelligence,defense,magic_defense,items=[])
      @health         = health
      @max_health     = health

      @mana           = mana
      @max_mana       = mana

      @strength       = strength
      @intelligence   = intelligence
      @defense        = defense
      @magic_defense  = magic_defense

      @items          = items.map { |item_type| Combat::Item.new item_type }
    end

    def initiative
      @strength + @intelligence
    end

    def attack
      base_damage  = rand(@strength)

      # Items bonus damage :
      bonus_damage  = @items.inject(0) do |total_damage,item|
                        total_damage += Combat::Item::ITEMS[item.type][:effects].inject(0) do |effects_damage,effect|
                                          effects_damage += ( effect[:attribute] == :strength ? effect[:value] : 0 )
                                        end
                      end

      { type:     :physical_attack,
        actor:    :player,
        damage:   base_damage + bonus_damage,
        message:  "You attack for #{base_damage}(+#{bonus_damage}) hits!" }
    end

    def get_hit(attack)
      damage  = case attack[:type]
                when :physical_attack then [ 0, attack[:damage] - @defense ].max
                when :magic_attack    then [ 0, attack[:damage] - @magic_defense ].max
                end

      @health -= damage
      @health = 0 if @health < 0

      { type:     :player_get_hit,
        actor:    :player,
        message:  "You get hit for #{damage} hits of #{attack[:type].to_s.split('_').first}." }
    end

    def is_dead?
      @health <= 0
    end

    def receive(item_type)
      @items << Combat::Item.new(item_type)

      { type:     :player_get_item,
        actor:    :player,
        message:  "You get a #{Combat::Item::ITEMS[item_type][:name]}." }
    end

    def use(item)
      item_template = Combat::Item::ITEMS[item.type]

      type    = :player_use_object
      damage  = 0
      message = "You use the #{item_template[:name]}."

      item_template[:effects].each do |effect|
        case effect[:category]
        when :modifier
          case effect[:attribute]
          when :health
            @health   = [ @max_health, @health + effect[:value] ].min
            message  += " Your health is now at #{@health}."
          when :mana
            @mana     = [ @max_mana,   @mana   + effect[:value] ].min
            message  += " Your mana is now at #{@mana}."
          end

        when :attack
          type      = :player_use_attack_object
          damage    = rand(effect[:hits_range])
          message  += "You deal #{damage} hits!" 

        when :magic_attack
          type      = :player_use_magic_attack_object
          damage    = rand(effect[:hits_range])
          message  += "You deal #{damage} hits!" 

        end
      end

      if item.usable?
        item.use
        @items.delete(item) if item.depleted?
      end

      { type:     type,
        actor:    :player,
        damage:   damage,
        message:  message }
    end
  end
end
