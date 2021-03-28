class GuildsController < ApplicationController

	before_action :check_user_guild_exist, only: [:create]
	before_action :check_user_guild_not_exist, only: [:add_officer, :leave_guild, :kick_member]
	before_action :check_target_not_exist, only: [:add_officer, :kick_member, :remove_officer]
	before_action :check_user_is_not_owner, only: [:add_officer, :kick_member, :remove_officer]
	before_action :check_target_is_not_member, only: [:add_officer, :kick_member, :remove_officer]
	before_action :check_target_is_officer, only: [:add_officer]
	before_action :check_target_is_officer, only: [:kick_member], unless: :check_user_is_owner
	before_action :check_target_is_not_officer, only: [:remove_officer]
	before_action :check_target_is_owner, only: [:kick_member]
	before_action :check_guilds_not_exist, only: [:show]
	before_action :check_user_alone, only: [:leave_guild], if: :check_user_is_owner

	def index
		@guilds = Guild.all
	end

	def new
		@guild = Guild.new
	end

	def create
		guild = Guild.new(guild_params)
		if guild.save
			guild.guild_members.create(user: current_user, owner: true)
			redirect_to guild_path(guild), success: "Guild was created"
		else
			redirect_to guilds_path, alert: "Can't create guild: #{ guild.errors.full_messages.join(", ") }"
		end
	end

	def show
		@guild = Guild.all.find(params[:id])
		@join_request = current_user.pending_join_requests.find_by(guild: @guild.id)
		@invite = current_user.pending_invites.find_by(guild: @guild.id)
		@guild_sending_invites = @guild.pending_invites_user
		@guild_incoming_invites = @guild.pending_join_request_user
		@wars_ended = @guild.wars_ended.order(ended: :desc)
	end

	def add_officer
		member = current_user.guild.members.find(params[:user_id])
		if member.guild_member.update_attribute(:officer, true)
			Notification.create(user: current_user, recipient: member, action: "add_officer", notifiable_type: "guilds",
								service_info: "#{ current_user.guild.name }")
			redirect_back fallback_location: guild_path(current_user.guild), success: "#{member.nickname} now an officer"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't add #{member.nickname} to officers"
		end
	end

	def remove_officer
		member = current_user.guild.members.find(params[:user_id])
		if member.guild_member.update_attribute(:officer, false)
			Notification.create(user: current_user, recipient: member, action: "remove_officer", notifiable_type: "guilds",
								service_info: "#{ current_user.guild.name }")
			redirect_back fallback_location: guild_path(current_user.guild), success: "Removed officer status for #{member.nickname}"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't delete #{member.nickname} from officers"
		end
	end

	def leave_guild
		guild = current_user.guild
		member = current_user.guild_member
		if member.delete
			if guild.guild_members.count == 0
				guild.destroy
			end
			redirect_to guilds_path, success: "You leave guild"
		else
			redirect_to guilds_path, allert: "You can't leave guild. Try again!"
		end
	end

	def kick_member
		guild = current_user.guild
		user = guild.members.find_by(id: params[:user_id])
		if user.guild_member.delete
			Notification.create(user: current_user, recipient: user, action: "kick", notifiable_type: "guilds",
																service_info: "#{ current_user.guild.name }")
			redirect_to guilds_path, success: "You kick #{user.nickname} from guild"
		else
			redirect_to guilds_path, allert: "Can't kick  #{user.nickname}. Try again!"
		end
	end

	private

	def guild_params
		if params[:guild][:anagram]
			params[:guild][:anagram] = params[:guild][:anagram].upcase
		end
		params.require(:guild).permit(:name, :description, :anagram, :avatar)
	end

	def check_user_guild_exist
		redirect_to guild_path(current_user.guild), alert: "You allready have a guild" if current_user.guild
	end

	def check_user_guild_not_exist
		redirect_to guilds_path, allert: "You don't have a guild" unless current_user.guild
	end

	def check_target_not_exist
		user = User.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "User not found" unless user
	end

	def check_user_is_not_owner
		redirect_to guild_path(current_user.guild), alert: "You are not a rights for this" unless current_user.guild_owner
	end

	def check_user_is_not_officer
		unless current_user.guild_officer
			return false
		else
			return true
		end
	end

	def check_target_is_not_member
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "Target not in you guild" unless member
	end

	def check_target_is_not_officer
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "#{member.nickname} is not officer" unless member.guild_officer
	end

	def check_target_is_officer
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "#{member.nickname} is officer" if member.guild_officer
	end

	def check_guilds_not_exist
		guild = Guild.all.find_by(id: params[:id])
		redirect_to guilds_path, alert: "Guild not found" unless guild
	end

	def check_user_alone
		redirect_to guilds_path, alert: "Guild owner can't leave guild" if current_user.guild_owner
	end

	def check_user_is_owner
		if current_user.guild_owner
			return true
		else
			return false
		end
	end

	def check_target_is_owner
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "#{member.nickname} is owner. What's goin on?" if member.guild_owner
	end 

end
