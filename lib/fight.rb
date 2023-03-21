module Combat
  class Fight
    attr_reader :players, :opponents, :actors

    def initialize(players,opponents)
      @players    = players
      @opponents  = opponents
      @actors     = @players + @opponents
    end

    def run
      @actors.sort { |actor| actor.initiative }.each do |actor|
        # Current actor action :
        menu_response   = chose_action_and_targets actor
        actor_response  = run_actor actor, menu_response

        # Target(s) reactions :
        actor_response[:targets].map do |target|
          run_actor target,
                    Combat::Message.retarget(actor_response, target)
        end
      end
    end

    def run_actor(actor,message)
      case message[:type]
      when :attack_selected       then actor.attack         message
      when :attack                then actor.got_hit        message
      when :cast_selected         then actor.cast           message
      when :cast
        message[:submessages].each { |submessage| run_actor actor, submessage }

      when :magic_attack          then  actor.got_magic_hit message
      when :use_selected          then  actor.use           message
      when :use
        message[:submessages].each { |submessage| run_actor actor, submessage }

      when :give_selected         then  actor.give          message
      when :wait_selected, :wait  then  actor.wait          message
      else                              actor.wait          message
      end
    end

    def chose_action_and_targets(actor)
    end

    def chose_spell(actor)
    end

    def chose_item(actor)
    end
  end
end
