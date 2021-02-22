class WarsController < ApplicationController

    def index
        @guild = Guild.find(params[:id])
        @wars = @guild.wars_all.order(:created_at)
    end

    def new
        @war = War.new
    end

    def create
        guild = Guild.find(params[:id])
        recipient = Guild.find_by(name: params[:war][:recipient])
        war = War.new(war_params)
        war.initiator = guild
        war.recipient = recipient
        war.started = DateTime.now
        if war.save
            redirect_to guild_wars_show_path(guild, war), success: "War request sended!"
        else
            redirect_to guild_wars_new_path(guild), alert: "Can't declare war: #{ war.errors.full_messages.join(", ") }"
        end
    end

    def show
        @war = War.find(params[:war_id])
    end

    def leave
    end

    private

    def war_params
	 	params.require(:war).permit(:daily_start, :daily_end,
                                    :time_to_wait, :max_unanswered,
                                    :ball_down_mode, :ball_speedup_mode,
                                    :random_mode, :ball_size,
                                    :speed_rate)
	end

end
