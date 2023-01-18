module Combat
  class Fight
    def initialize(player,monster)
      @player   = player
      @monster  = monster

      @monster_has_initiative = if @player.initiative <= @monster.initiative
    end

    def run
      run_monster if @monster_has_initiative

      while true do
        run_player
        break if @player.is_dead?

        run_monster
        break if @monster.is_dead?
      end
    end

    def run_player
    end

    def run_monster
    end
  end
end
