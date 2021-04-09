class RoomMessagesController < ApplicationController
	before_action :load_entities
	before_action :check_room_exist, only: [:create]
	before_action :is_member, only: [:create]
	before_action :is_banned, only: [:create]
	before_action :is_muted, only: [:create]

	def create
		@room_message = RoomMessage.create user: current_user, room: @room, message: params.dig(:room_message, :message)
		RoomChannel.broadcast_to @room, @room_message
	end
  
private  
	def load_entities
	  @room = Room.all.find_by(id: params.dig(:room_message, :room_id))
	  if !@room
		redirect_back fallback_location: root_path, alert: "Not a member!"
	  end
	end

	def check_room_exist
		redirect_to rooms_path, alert: "Roomds not exist" if !@room
	end

	def is_member
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		redirect_back fallback_location: root_path, alert: "Not a member!" if !record
	end

	def is_banned
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		redirect_to rooms_path, alert: "banned" if record && record.banned && !current_user.admin
	end

	def is_muted
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		if current_user.admin
			return
		end
		redirect_to room_path(@room), alert: "You are muted!" if record.muted
	end
end
