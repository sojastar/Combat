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
      when :attack_selected then actor.attack   message
      when :attack          then actor.get_hit  message
      when :cast_selected   then actor.cast     message
      when :cast
        message[:submessages].each { |submessage| run_actor actor, submessage }
      #when :use_selected    then actor.use      message
      end
    end

    def chose_action_and_targets(actor)
    end
  end
end
