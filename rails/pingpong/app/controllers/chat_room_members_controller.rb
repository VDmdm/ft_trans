class ChatRoomMembersController < ApplicationController

	before_action :check_password, only: [:create]


	def new
		member = ChatRoomMember.new(user: current_user, room_id: params[:room_id])
		if member.save
			redirect_to room_path(member.room_id)
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end

	def create
		member = ChatRoomMember.new(user: current_user, room_id: params[:room_id])
		if member.save
			redirect_to room_path(member.room_id)
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end

	def leave
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		if record.owner
			room = Room.find_by(id: params[:room_id])
			room.destroy
			redirect_to rooms_path
		elsif record.destroy
			redirect_to room_path(params[:room_id])
		else
			redirect_to room_path(params[:room_id]), alert: "Can't leave"
		end
	end

	def block
		block = BlockedUser.new(user_id: current_user.id, blocked_id: params[:blocked_id])
		if block.save
			redirect_to room_path(params[:room_id]), success: "User have been blocked"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to block user"
		end
	end

	def unblock
		block = BlockedUser.all.find_by(user_id: current_user.id, blocked_id: params[:blocked_id])
		if block.destroy
			redirect_to room_path(params[:room_id]), success: "User have been unblocked"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to unblock user"
		end
	end

	def ban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:banned, true)
			redirect_to room_path(params[:room_id]), success: "Successfully banned"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to ban"
		end
		# <%= link_to "decline join request", decline_join_request_path(@guild, user_id: member), method: :post, remote: true %>
	end

	def unban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:banned, false)
			redirect_to room_path(params[:room_id]), success: "Successfully unbanned"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to unban"
		end
	end

	def make_admin
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:admin, true)
			redirect_to room_path(params[:room_id]), success: "Successfully added to admins!"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to made admin"
		end
	end

	def remove_admin
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:admin, false)
			redirect_to room_path(params[:room_id]), success: "Successfully removed from admins!"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to remove admin"
		end
	end

	def mute
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:muted, true)
			redirect_to room_path(params[:room_id]), success: "Successfully muted"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to mute"
		end
	end

	def unmute
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:muted, false)
			redirect_to room_path(params[:room_id]), success: "Successfully unmuted"
		else
			redirect_to room_path(params[:room_id]), alert: "Failed to unmute"
		end
	end


	def check_password
		redirect_to rooms_path, alert: "incorrect password" if params[:password] != Room.all.find_by(id: params[:room_id]).password
	end
end
