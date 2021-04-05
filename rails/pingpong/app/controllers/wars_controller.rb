class WarsController < ApplicationController
    
    before_action :check_guilds_not_exist, only: [:create, :accept_war_request, :cancel_war_request, :decline_war_request]
    before_action :check_recipient_not_exist, only: [:create]
    before_action :check_guild_is_a_initiator, only: [:create]
    before_action :check_guild_already_active_war_not_exist, only: [:create, :accept_war_request, :cancel_war_request, :decline_war_request]
    before_action :check_guild_already_sent_war_request, only: [:create]
    before_action :check_guild_already_have_received_war_request, only: [:create]
    before_action :check_user_is_not_officer, only: [:create, :accept_war_request, :cancel_war_request, :decline_war_request], unless: :check_user_is_not_owner
    before_action :check_current_user_is_not_officer, only: [:new], unless: :check_current_user_is_not_owner
    before_action :check_wars_not_exist, only: [:show]
    before_action :check_war_request_not_exist, only: [:accept_war_request, :cancel_war_request, :decline_war_request]

    def index
        @guild = Guild.find(params[:id])
        @wars_ended = @guild.wars_ended.order(ended: :desc)
        @war_active = @guild.war_active
        @wars_request_sent = @guild.wars_request_sent
        @wars_request_received = @guild.wars_request_received
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
        if war.save
            WarStartJob.set(wait_until: war.started).perform_later(war.id)
            redirect_to guild_wars_show_path(war), success: "War request sended!"
        else
            redirect_to guild_wars_new_path(guild), alert: "Can't declare war: #{ war.errors.full_messages.join(", ") }"
        end
    end

    def show
		@war = War.find(params[:id])
		@war_games = @war.wartimes
    end

    def accept_war_request
        guild = Guild.find_by(id: params[:id])
        war = War.find_by(id: params[:war_id])
        war.update_attribute(:status, :wait_start)
        war.recipient.update_attribute(:points, war.recipient.points - war.prize)
        war.initiator.update_attribute(:points, war.initiator.points - war.prize)
        redirect_to guild_wars_show_path(war), success: "War request accepted!"
    end

    def cancel_war_request
        guild = Guild.find_by(id: params[:id])
        war = War.find_by(id: params[:war_id])
        war.delete
        redirect_to guild_wars_index_path(guild), success: "War request canceled!"
    end

    def decline_war_request
        guild = Guild.find_by(id: params[:id])
        war = War.find_by(id: params[:war_id])
        war.update_attribute(:status, :declined)
        redirect_to guild_wars_index_path(guild), success: "War request declined!"
    end

    private

    def war_params
	 	params.require(:war).permit(:daily_start, :daily_end,
                                    :time_to_wait, :max_unanswered,
                                    :ball_down_mode, :ball_speedup_mode,
                                    :random_mode, :ball_size, :prize,
                                    :speed_rate, :started, :ended)
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
        redirect_to guild_path(guild), alert: "You already have a war" if guild.war_active
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

    def check_user_is_not_officer
        guild = Guild.all.find_by(id: params[:id])
        redirect_to guilds_path, alert: "You not have rights for this" unless guild.officers.include?(current_user)
    end

    def check_user_is_not_owner
        guild = Guild.all.find_by(id: params[:id])
        return guild.owner == current_user
    end

    def check_current_user_is_not_officer
        redirect_to guilds_path, alert: "You not have rights for this" unless current_user.guild && current_user.guild_officer
    end

    def check_current_user_is_not_owner
        return current_user.guild && current_user.guild_owner
    end

    def check_guild_is_a_initiator
        guild = Guild.all.find_by(id: params[:id])
        initiator = Guild.find_by(name: params[:war][:recipient])
        redirect_to guild_path(guild), alert: "Can't declare war youre own guild" if guild == initiator
    end

    def check_wars_not_exist
		war = War.find_by(id: params[:id])
		redirect_to guilds_path, alert: "War not found" unless war
    end
    
    def check_war_request_not_exist
        guild = Guild.all.find_by(id: params[:id])
        war = War.find_by(id: params[:war_id])
        redirect_to guild_path(guild), alert: "War request not found" if !war || war.status != "send_request"
    end

end
