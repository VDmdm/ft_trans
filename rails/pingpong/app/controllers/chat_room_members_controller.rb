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

	def ban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:banned, true)
			redirect_to room_path(params[:room_id]), success: "Successfully banned"
		else
			redirect_to room_path(params[:room_id]), success: "Failed to ban"
		end
		# <%= link_to "decline join request", decline_join_request_path(@guild, user_id: member), method: :post, remote: true %>
	end

	def unban
		record = ChatRoomMember.all.find_by(user_id: params[:user_id], room_id: params[:room_id])
		
		if record.update_attribute(:banned, false)
			redirect_to room_path(params[:room_id]), success: "Successfully unbanned"
		else
			redirect_to room_path(params[:room_id]), success: "Failed to unban"
		end
	end

	def make_admin
		
	end

	def remove_admin

	end

	def mute

	end

	def unmute

	end


	def check_password
		redirect_to rooms_path, alert: "incorrect password" if params[:password] != Room.all.find_by(id: params[:room_id]).password
	end
end
