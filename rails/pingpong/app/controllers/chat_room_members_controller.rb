class ChatRoomMembersController < ApplicationController

	before_action :check_room_exist, except: [:block, :unblock]
	before_action :check_if_member, only: [:leave, :ban, :unban, :mute, :unmute, :make_admin, :remove_admin, :kick]
	before_action :check_if_yourself, only: [:ban, :unban, :mute, :unmute, :make_admin, :remove_admin, :kick]
	before_action :check_rights, only: [:ban, :unban, :mute, :unmute, :kick]
	before_action :check_owner_rights, only: [:make_admin, :remove_admin]
	before_action :check_if_on_owner, only: [:ban, :unban, :mute, :unmute, :kick]
	before_action :check_if_on_admin , only: [:ban, :unban, :mute, :unmute, :kick]
	before_action :check_if_banned, only: [:new, :create, :ban, :make_admin]
	before_action :check_user_existence, only: [:block, :unblock]
	before_action :check_if_block_yourself, only: [:block, :unblock]
	before_action :check_if_already_blocked, only: [:block, :unblock]
	before_action :check_password, only: [:create]


	def new
		member = ChatRoomMember.new(user: current_user, room_id: params[:id])
		if member.save
			redirect_to room_path(member.room_id)
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end

	def create
		member = ChatRoomMember.new(user: current_user, room_id: params[:id])
		if member.save
			redirect_to room_path(member.room_id)
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end

	def params_validator
		params.require(:rooms).permit(:id, :user_id)
	end

	def leave
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		if record.owner
			room = Room.find_by(id: params[:id])
			room.destroy
			redirect_to rooms_path
		elsif record.destroy
			redirect_to room_path(params[:id])
		else
			redirect_to room_path(params[:id]), alert: "Can't leave"
		end
	end

	def kick
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])

		if record.destroy
			redirect_to room_path(params[:id])
		else
			redirect_to room_path(params[:id]), alert: "Can't leave"
		end
	end

	def block
		block = BlockedUser.new(user_id: current_user.id, blocked_id: params[:blocked_id])
		if block.save
			redirect_back fallback_location: root_path, success: "User have been blocked"
		else
			redirect_back fallback_location: root_path, alert: "Failed to block user"
		end
	end

	def unblock
		block = BlockedUser.all.find_by(user_id: current_user.id, blocked_id: params[:blocked_id])
		if block.destroy
			redirect_back fallback_location: root_path, success: "User have been unblocked"
		else
			redirect_back fallback_location: root_path, alert: "Failed to unblock user"
		end
	end

	def ban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:banned, true)
			redirect_to room_path(params[:id]), success: "Successfully banned"
		else
			redirect_to room_path(params[:id]), alert: "Failed to ban"
		end
		# <%= link_to "decline join request", decline_join_request_path(@guild, user_id: member), method: :post, remote: true %>
	end

	def unban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:banned, false)
			redirect_to room_path(params[:id]), success: "Successfully unbanned"
		else
			redirect_to room_path(params[:id]), alert: "Failed to unban"
		end
	end

	def make_admin
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:admin, true)
			redirect_to room_path(params[:id]), success: "Successfully added to admins!"
		else
			redirect_to room_path(params[:id]), alert: "Failed to made admin"
		end
	end

	def remove_admin
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:admin, false)
			redirect_to room_path(params[:id]), success: "Successfully removed from admins!"
		else
			redirect_to room_path(params[:id]), alert: "Failed to remove admin"
		end
	end

	def mute
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:muted, true)
			redirect_to room_path(params[:id]), success: "Successfully muted"
		else
			redirect_to room_path(params[:id]), alert: "Failed to mute"
		end
	end

	def unmute
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		
		if record.update_attribute(:muted, false)
			redirect_to room_path(params[:id]), success: "Successfully unmuted"
		else
			redirect_to room_path(params[:id]), alert: "Failed to unmute"
		end
	end


	def check_password
		redirect_to rooms_path, alert: "incorrect password" if params[:password] != Room.all.find_by(id: params[:id]).password
	end




	def check_room_exist
		redirect_to rooms_path, alert: "Room not exist" if !Room.all.find_by(id: params[:id])
	end

	def check_if_banned
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		redirect_to rooms_path, alert: "banned" if record and record.banned
	end

	def check_if_member
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		redirect_to rooms_path, alert: "Not a member!" if !record
	end

	def check_if_yourself
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		redirect_to rooms_path, alert: "Can't do on yourself!" if record.user_id == current_user.id
	end

	def check_user_existence
		if params[:blocked_id]
			usr = User.all.find(params[:blocked_id])
			redirect_to rooms_path, alert: "User doesn't exist!" if !usr
		end
	end
	def check_if_block_yourself
		if params[:blocked_id]
			redirect_to rooms_path, alert: "Can't block or unblock yourself!" if (current_user.id == params[:blocked_id].to_i)
		end
	end

	def check_if_already_blocked
		if params[:blocked_id]
			record = BlockedUser.find_by(blocked_id: params[:user_id])
			redirect_to rooms_path, alert: "Already blocked!" if record
		end
	end

	def check_rights
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: params[:id])
		redirect_to rooms_path, alert: "Don't have enough rights!" if !record.admin and !record.owner
	end

	def check_owner_rights
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: params[:id])
		redirect_to rooms_path, alert: "Don't have enough rights!" if !record.owner
	end

	def check_if_on_owner
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		redirect_to rooms_path, alert: "Don't have enough rights!" if record.owner
	end

	def check_if_on_admin
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:id])
		record2 = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: params[:id])
		redirect_to rooms_path, alert: "Don't have enough rights!" if !record2.owner and record.admin
	end

end
