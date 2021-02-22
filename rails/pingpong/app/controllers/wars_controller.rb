class WarsController < ApplicationController
    
    before_action :check_guilds_not_exist, only: [:create]
    before_action :check_recipient_not_exist, only: [:create]
    before_action :check_guild_already_active_war_not_exist, only: [:create]
    before_action :check_guild_already_sent_war_request, only: [:create]
    before_action :check_guild_already_have_received_war_request, only: [:create]

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
            redirect_to guild_wars_show_path(war), success: "War request sended!"
        else
            redirect_to guild_wars_new_path(guild), alert: "Can't declare war: #{ war.errors.full_messages.join(", ") }"
        end
    end

    def show
        @war = War.find(params[:id])
    end

    def leave
    end

    def accept_war_request
    end

    def cancel_war_request
    end

    def decline_war_request
    end

    private

    def war_params
	 	params.require(:war).permit(:daily_start, :daily_end,
                                    :time_to_wait, :max_unanswered,
                                    :ball_down_mode, :ball_speedup_mode,
                                    :random_mode, :ball_size,
                                    :speed_rate)
	end

    def check_guilds_not_exist
		guild = Guild.all.find_by(id: params[:id])
		redirect_to guilds_path, alert: "Guild not found" unless guild
	end
    
    def check_recipient_not_exist
        recipient = Guild.find_by(name: params[:war][:recipient])
        redirect_to guild_wars_new_path, alert: "Guild not found" unless recipient
    end

    def check_guild_already_active_war_not_exist
        guild = Guild.all.find_by(id: params[:id])
        redirect_to guild_path(guild), alert: "You already have a war" unless guild.wars_active.blank?
    end

    def check_guild_already_sent_war_request
        guild = Guild.all.find_by(id: params[:id])
        recipient = Guild.find_by(name: params[:war][:recipient])
        redirect_to guild_path(guild), alert: "You already sent request to #{ recipient.name }" if guild.wars_request_sent.find_by(recipient: recipient)
    end

    def check_guild_already_have_received_war_request
        guild = Guild.all.find_by(id: params[:id])
        initiator = Guild.find_by(name: params[:war][:recipient])
        redirect_to guild_path(guild), alert: "You already have incoming war request from #{ initiator.name }" if guild.wars_request_received.find_by(initiator: initiator)
    end

end
