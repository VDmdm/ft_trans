class GuildInvitesController < ApplicationController

	before_action :check_target_not_exist, only: [:send_invite, :cancel_invite, :accept_join_request]
	before_action :check_user_guild_not_exist, only: [:send_invite, :cancel_invite, :accept_join_request]
	before_action :check_user_guild_exist, only: [:send_join_request]
	before_action :check_guild_not_exist, only: [:send_join_request, :cancel_invite, :accept_join_request]
	before_action :check_target_guild_exist, only: [:send_invite, :accept_join_request]
	before_action :check_user_is_not_owner, only: [:send_invite, :cancel_invite, :accept_join_request], unless: :check_user_is_not_officer
	before_action :check_invite_or_request_is_exist, only: [:send_invite]
	before_action :check_invite_or_request_not_exist, only: [:cancel_invite, :accept_join_request]


	def send_invite
		user = User.find(params[:user_id])
		if current_user.guild.guild_invites.create(user: user, invited_by: current_user)
			redirect_back fallback_location: guild_path(current_user.guild), success: "#{user.nickname} has been invited to you guild"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't invite #{user.nickname} to guild"
		end
	end

	def send_join_request
		guild = Guild.find(params[:id])
		invite = GuildInvite.new(guild: guild, user: current_user, dir: :join_request)
		if invite.save
			redirect_back fallback_location: guild_path(guild), success: "You join request has been sent"
		else
			redirect_back fallback_location: guild_path(guild), alert: "Can't send join request"
		end
	end


	def accept_invite
		guild = Guild.find(params[:id])
		invite = guild.guild.pending_invite.find_by(user: current_user)
		if invite.update_attribute(:status, :accept)
			if (guild.guild_member.create(user: invite.user))
				redirect_back fallback_location: guild_path(guild), success: "You have successsfully joined guild #{ guild.name }"
			else
				redirect_back fallback_location: guild_path(guild), alert: "#Can't accepting штмшеу. Try join again"
			end
		else
			redirect_back fallback_location: guild_path(guild), alert: "Can't accept invite"
		end
	end

	def cancel_invite
		invite = current_user.guild.pending_invites.find_by(user: params[:user_id])
		if invite.delete
			redirect_back fallback_location: guild_path(current_user.guild), success: "Invite has been canceled"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't dicline invite"
		end
	end

	def accept_join_request
		guild = Guild.find(params[:id])
		invite = guild.pending_join_request.find_by(user: params[:user_id])
		if invite.update_attribute(:status, :accept)
			if (guild.guild_member.create(user: invite.user))
				redirect_back fallback_location: guild_path(guild), success: "#{ invite.user.nickname } now in you guild"
			else
				redirect_back fallback_location: guild_path(guild), alert: "#Can't accepting join request. Try invite again"
			end
		else
			redirect_back fallback_location: guild_path(guild), alert: "Can't accept join request"
		end
	end

	def cancel_join_request
		guild = Guild.find(params[:id])
		invite = guild.pending_join_request.find_by(user: params[:user_id])
		if invite.delete
			redirect_back fallback_location: guild_path(guild), success: "Join request has been canceled"
		else
			redirect_back fallback_location: guild_path(guild), alert: "Can't cancel join request"
		end
	end

	private

	def check_user_guild_not_exist
		redirect_to guilds_path, allert: "You don't have a guild" unless current_user.guild
	end

	def check_user_guild_exist
		redirect_to guilds_path, allert: "You allready in guild" if current_user.guild
	end

	def check_target_guild_exist
		user = User.find(params[:user_id])
		redirect_to guilds_path, allert: "#{ user.nickname } allready in guild" if user.guild
	end

	def check_guild_not_exist
		guild = Guild.find_by(id: params[:id])
		redirect_to guilds_path, allert: "Guild not found" unless guild
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

	def check_invite_or_request_is_exist
		guild = Guild.find_by(id: params[:id])
		user = User.find(params[:user_id])
		redirect_to guilds_path, alert: "invite/request allready is sending" if 
					guild.pending_invites_and_requests?(user)
	end

	def check_invite_or_request_not_exist
		guild = Guild.find_by(id: params[:id])
		user = User.find(params[:user_id])
		redirect_to guilds_path, alert: "invite/request not found" unless 
					guild.pending_invites_and_requests?(user)
	end

end
