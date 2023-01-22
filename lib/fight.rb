module Combat
  class Fight
    attr_reader :player, :monster,
                :is_on

    def initialize(player,monster)
      @player   = player
      @monster  = monster

      @current_actor  = @player.initiative >= @monster.initiative ? @player : @monster

      @is_on  = true
    end

    def roll_dice() rand end

    def run
      case @current_actor
      when @player  then run_player
      when @monster then run_monster
      end
    end

    def switch_to_player()  @current_actor  = @player   end
    def switch_to_monster() @current_actor  = @monster  end

    def run_player
        step  = @player.run

        message       = step[:message]
        should_print  = true
        case step[:type]
        when /attack/
          hit       = @monster.hit step
          message  += ' ' + hit[:message]

        when /done/
          @player.end_turn
          switch_to_monster
          should_print = false

        when /escape/
          @is_on = false

        end

        { player_status:  :alive,
          monster_status: @monster.alive? ? :alive : :dead,
          message:        message,
          should_print:   should_print }
    end

    def run_monster
      attack  = @monster.attack roll_dice 
      hit     = @player.hit attack

      switch_to_player

      { player_status:  @player.alive? ? :alive : :dead,
        monster_status: :alive,
        message:        attack[:message] + "\n" + hit[:message],
        should_print:   true }
    end
  end
end
