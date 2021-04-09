class DirectMessagesController < ApplicationController
	before_action :check_is_member, only: [:create]
	before_action :check_if_blocked, only: [:create]
	before_action :check_if_blocked_by, only: [:create]
	
	def create
		@room = DirectRoom.find params.dig(:direct_message, :direct_room_id)
		@room_message = DirectMessage.create user: current_user, direct_room: @room, message: params.dig(:direct_message, :message)
		DirectChannel.broadcast_to @room, @room_message
	end


	def check_is_member
		@room = DirectRoom.find params.dig(:direct_message, :direct_room_id)
		res = current_user.id == @room.user_id
		res = current_user.id == @room.dude_id if !res
		redirect_back fallback_location: root_path, alert: "Not a member" if !res
	end
	
	def check_if_blocked
		@room = DirectRoom.find params.dig(:direct_message, :direct_room_id)

		user = @room.user
		user = User.all.find_by(id: @room.dude_id) if user == current_user

		redirect_back fallback_location: root_path, alert: "User is blocked!" if current_user.is_blocked?(user)
	end

	def check_if_blocked_by
		@room = DirectRoom.find params.dig(:direct_message, :direct_room_id)
		usr = @room.user
		usr = User.all.find_by(id: @room.dude_id) if usr == current_user

		blocked_users = current_user.blocked_by
		blocked_users.each do |user|
			redirect_back fallback_location: root_path, alert: "You are blocked by this user!" if user.id == usr.id
		end
	end
end
