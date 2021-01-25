class GuildsController < ApplicationController

	before_action :check_user_guild_exist, only: [:create]
	before_action :check_user_guild_not_exist, only: [:add_officer, :add_member]
	before_action :check_target_not_exist, only: [:add_officer, :add_member]
	before_action :check_user_is_not_owner, only: [:add_officer, :add_member], unless: :check_user_is_not_officer
	before_action :check_invite_is_exist, only: [:add_member]
	before_action :check_target_is_not_member, only: [:add_officer]
	before_action :check_target_in_guild, only: [:add_member]
	#before_action :check_target_is_not_officer, only: [:add_officer]
	before_action :check_target_is_officer, only: [:add_officer]
	before_action :check_guilds_not_exist, only: [:show]

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
			redirect_to guild_path(guild)
		else
			redirect_to root_path
		end
	end

	def show
		@guild = Guild.all.find(params[:id])
	end

	def add_officer
		member = current_user.guild.members.find(params[:user_id])
		if member.guild_member.update_attribute(:officer, true)
			redirect_back fallback_location: guild_path(current_user.guild), succes: "#{member.nickname} now an officer"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't add #{member.nickname} to officers"
		end
	end

	def add_member
		user = User.find(params[:user_id])
		if current_user.guild.guild_invites.create(user: user, invited_by: current_user)
			redirect_back fallback_location: guild_path(current_user.guild), succes: "#{user.nickname} has been invited to you guild"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't invite #{user.nickname} to guild"
		end
	end

	private

	def guild_params
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

	def check_target_in_guild
		user = User.find(params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "Target allready in guild" if user.guild
	end

	def check_target_is_not_officer
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "#{member.nickname} is not officer" unless member.guild_officer
	end

	def check_target_is_officer
		member = current_user.guild.members.find_by(id: params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "#{member.nickname} already officer" if member.guild_officer
	end

	def check_guilds_not_exist
		guild = Guild.all.find_by(id: params[:id])
		redirect_to guilds_path, alert: "Guild not found" unless guild
	end

	def check_invite_is_exist
		user = User.find(params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "invite allready is sending" if 
					current_user.guild.pending_incoming_invites_user.find_by(id: user.id) ||
					current_user.guild.pending_sending_invites_user.find_by(id: user.id)
	end

end
