class GuildInvitesController < ApplicationController

	before_action :check_user_guild_not_exist, only: [:send_invite, :decline_invite, :accept_invite]
	before_action :check_target_not_exist, only: [:send_invite, :decline_invite, :accept_invite]
	before_action :check_user_is_not_owner, only: [:send_invite, :decline_invite, :accept_invite], unless: :check_user_is_not_officer
	before_action :check_invite_is_exist, only: [:send_invite]
	before_action :check_invite_not_exist, only: [:decline_invite, :accept_invite]
	before_action :check_target_in_guild, only: [:send_invite]


	def send_invite
		user = User.find(params[:user_id])
		if current_user.guild.guild_invites.create(user: user, invited_by: current_user)
			redirect_back fallback_location: guild_path(current_user.guild), succes: "#{user.nickname} has been invited to you guild"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't invite #{user.nickname} to guild"
		end
	end

	def decline_invite
		invite = current_user.guild.pending_invites.find_by(user: params[:user_id])
		if invite.update_attribute(:status, :decline)
			redirect_back fallback_location: guild_path(current_user.guild), succes: "Invite has been canceled"
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't dicline invite"
		end
	end

	def accept_invite
		invite = current_user.guild.pending_incoming_invites.find_by(user: params[:user_id])
		if invite.update_attribute(:status, :accept)
			if (current_user.guild.guild_member.create(user: invite.user))
				redirect_back fallback_location: guild_path(current_user.guild), succes: "#{ invite.user.nickname } now in you guild"
			else
				redirect_back fallback_location: guild_path(current_user.guild), alert: "#Can't accepting invite. Try invite again"
			end
		else
			redirect_back fallback_location: guild_path(current_user.guild), alert: "Can't dicline invite"
		end
	end

	private

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

	def check_invite_is_exist
		user = User.find(params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "invite allready is sending" if 
					current_user.guild.pending_invites?(user)
	end

	def check_invite_not_exist
		user = User.find(params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "invite not found" unless 
					current_user.guild.pending_invites?(user)
	end

	def check_target_in_guild
		user = User.find(params[:user_id])
		redirect_to guild_path(current_user.guild), alert: "Target allready in guild" if user.guild
	end

end
