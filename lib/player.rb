module Combat
  class Player
    ############################################################################
    # 1. CONSTANTS :
    ############################################################################
    ACTIONS = [ { text:   '(a)ttack',
                  key:    'a',
                  method: :attack },
                #{ text:   '(C)ast spell',
                #  key:    'c',
                #  method: :cast },
                { text:   '(u)se item',
                  key:    'u',
                  method: :use },
                { text:   '(e)scape',
                  key:    'e',
                  method: :escape } ]

    SPELLS  = []
    

    ############################################################################
    # 2. BASIC ACCESSORS :
    ############################################################################
    attr_reader :health, :max_health,
                :mana, :max_mana,
                :strength,
                :intelligence,
                :defense, :magic_defense,
                :items,
                :spells


    ############################################################################
    # 3. INITIALIZATION :
    ############################################################################
    def initialize(health,mana,strength,intelligence,defense,magic_defense,items=[],spells=[])
      @health         = health
      @max_health     = health

      @mana           = mana
      @max_mana       = mana

      @strength       = strength
      @intelligence   = intelligence
      @defense        = defense
      @magic_defense  = magic_defense

      @items          = items.map { |item_type| Combat::Item.new item_type }
      @spells         = [] # for now !

      begin_turn
    end


    ############################################################################
    # 4. OTHER ACCESSORS :
    ############################################################################
    def initiative() @strength + @intelligence end

    def alive?()  @health > 0   end
    def dead?()   @health <= 0  end

    def begin_turn()            @state  = :begin_turn             end
    alias end_turn begin_turn
    def wait_for_action_input() @state  = :wait_for_action_input  end
    def wait_for_spell_input()  @state  = :wait_for_spell_input   end
    def wait_for_item_input()   @state  = :wait_for_item_input    end
    def done_waiting()          @state  = :done_waiting           end
    def just_began_turn?()              @state == :begin_turn             end
    def is_waiting_for_action_input?()  @state == :wait_for_action_input  end
    def is_waiting_for_spell_input?()    @state == :wait_for_spell_input   end
    def is_waiting_for_item_input?()    @state == :wait_for_item_input    end
    def is_done_waiting?()              @state == :done_waiting           end
    
    def status() "health:#{@health}, mana: #{@mana}" end

    def menu() ACTIONS.map { |action| action[:text] }.join(' - ') end


    ############################################################################
    # 5. RESOLVE TURN :
    ############################################################################
    def run
      case
      when just_began_turn?
        wait_for_action_input

        { type:     :player_waits_for_input,
          message:  status + " | " + menu }

      when is_waiting_for_action_input?
        action_key = STDIN.getch

        case action_key
        when 'a'    # Attack
          done_waiting
          attack

        when 'c'    # Cast a spell
          wait_for_spell_input 
          
          { type:     :player_waits_for_input,
            message:  choices(@spells, 'No spells') + ' | (Esc) Cancel' }

        when 'u'    # Use
          wait_for_item_input
          
          { type:     :player_waits_for_input,
            message:  choices(Item.usable(@items), 'No items') + ' | (Esc) Cancel' }

        when 'e'    # Escape
          done_waiting
          escape

        end

      when is_waiting_for_spell_input?

      when is_waiting_for_item_input?
        item_key  = STDIN.getch

        if item_key == "\e"
          wait_for_action_input

          { type:     :player_cancel,
            message:  status + " | " + menu }

        else
          done_waiting
          use Item.usable(@items).at(char_to_index(item_key))

        end

      when is_done_waiting?
        { type: :player_done }

      end
    end

    def choices(list, empty_message='Empty')
      if list.empty?
        empty_message

      else
        ('a'..'z').to_a.slice(0, list.length).map.with_index do |c,i|
          "(#{c}) #{list[i].name}(#{list[i].uses})"
        end
        .join(' - ')

      end
    end

    def char_to_index(char)
      ('a'..'z').to_a.index(char)
    end


    ############################################################################
    # 6. ACTIONS :
    ############################################################################
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

    def cast(spell)
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
          type      = :attack
          damage    = rand(effect[:hits_range])
          message  += " You deal #{damage} hits!" 

        when :magic_attack
          type      = :magic_attack
          damage    = rand(effect[:hits_range])
          message  += " You deal #{damage} hits!" 

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

    def escape
      damage    = rand ( @max_health * 0.1 ).ceil
      @health  -= damage

      if @health > 0
        { type:     :player_escape,
          actor:    :player,
          message:  "You manage to escape but get hit in the back for #{damage} damage..." }

      else
        { type:     :player_escape,
          actor:    :player,
          message:  "You try to escape but get hit in the back for #{damage} damage..." }

      end
    end


    ############################################################################
    # 7. REACTIONS :
    ############################################################################
    def hit(attack)
      result  = case attack[:type]
                when :physical_attack
                  if defense > 0
                    if defense >= attack[:damage]
                      { damage:   0,
                        message:  "Your armor blocks all the damage..." }

                    else
                      damage  = attack[:damage] - defense
                      message = "Your armor blocks #{defense} damage. "\
                                "You get #{damage} damage."
                      { damage: damage, message: message }

                    end

                  else
                    { damage: attack[:damage],
                      message:  "You get #{attack[:damage]} damage." }

                  end

                when :magic_attack
                  if magic_defense > 0
                    if magic_defense >= attack[:damage]
                      { damage:   0,
                        message:  "Your magic armor blocks all the damage..." }

                    else
                      damage  = attack[:damage] - magic_defense
                      message = "Your magic armor blocks #{magic_defense} damage. "\
                                "You get #{damage} magic damage."
                      { damage: damage, message: message }

                    end

                  else
                    { damage: attack[:damage],
                      message:  "You get #{attack[:damage]} magic damage." }

                  end

                end

      @health -= result[:damage]

      { type:     :player_get_hit,
        actor:    :player,
        message:  result[:message] }
    end

    def receive(item_type)
      @items << Combat::Item.new(item_type)

      { type:     :player_get_item,
        actor:    :player,
        message:  "You get a #{Combat::Item::ITEMS[item_type][:name]}." }
    end
  end
end
