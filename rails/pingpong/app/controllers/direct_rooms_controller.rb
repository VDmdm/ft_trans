class DirectRoomsController < ApplicationController
	before_action :check_user_exist, only: [:find_room]
	before_action :check_room_exist, only: [:find_room]
	before_action :check_room_exist_show, only: [:show]
	before_action :check_is_member, only: [:show]

	# before_action :check_user_blocked, only: [:find_room]
	# before_action :check_user_blocked_show, only: [:show]

	before_action :check_user_existence, only: [:block, :unblock]
	before_action :check_if_block_yourself, only: [:block, :unblock]
	before_action :check_if_already_blocked, only: [:block, :unblock]

	def show
		@room = DirectRoom.find(params[:id])
		@room_message = DirectMessage.new direct_room: @room
		@room_messages = @room.direct_messages.includes(:user)
		@dude = @room.user
		@dude = User.all.find(@room.dude_id) if @dude == current_user
	end

	def destroy
		@room = DirectRoom.find(params[:id])
		@room.destroy
		redirect_to rooms_path, success: "Chat deleted"
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


	def find_room
		@room = DirectRoom.all.find_by(user_id: current_user.id, dude_id: params[:user_id])
		@room = DirectRoom.all.find_by(user_id: params[:user_id], dude_id: current_user.id) if !@room
		redirect_to direct_room_path(@room)
	end

	def check_user_exist
		usr = User.all.find_by(id: params[:user_id])
		redirect_to rooms_path, alert: "User not exist" if !usr
	end

	def check_room_exist
		case1 = DirectRoom.find_by(user_id: current_user.id, dude_id: params[:user_id])
		case2 = DirectRoom.find_by(user_id: params[:user_id], dude_id: current_user.id)
		if !case1 and !case2
			DirectRoom.create(user_id: current_user.id, dude_id: params[:user_id])
		end
	end

	def check_room_exist_show
		existence = DirectRoom.find_by(id: params[:id])
		redirect_to rooms_path, alert: "Not such direct room" if !existence
	end

	def check_is_member
		room = DirectRoom.all.find_by(id: params[:id], user_id: current_user.id)
		room = DirectRoom.all.find_by(id: params[:id], dude_id: current_user.id) if !room
		redirect_to rooms_path, alert: "Not a member" if !room
	end

	# def check_user_blocked_show
	# 	room = DirectRoom.find_by(id: params[:id])
	# 	if current_user == room.user
	# 		dude = User.all.find(room.dude_id)
	# 	else
	# 		dude = room.user
	# 	end
	# 	p 'dasdsagsdjdjfsdjhajfsdjfdhsdhfhsdhsdfhsdshf'
	# 	p dude
	# 	redirect_to rooms_path, alert: "User is blocked" if current_user.is_blocked?(dude)

	# 	blocked_users = current_user.blocked_by
	# 	blocked_users.each do |user|
	# 		redirect_to rooms_path, alert: "You are blocked by this user!" if user.id == dude.id
	# 	end

	# end

	def check_if_blocked
		record = BlockedUser.find_by(user_id: current_user.id, blocked_id: params[:user_id])
		redirect_to rooms_path, alert: "User is blocked!" if record
	end

	def check_if_blocked_by
		
		blocked_users = current_user.blocked_by
		blocked_users.each do |user|
			redirect_to rooms_path, alert: "You are blocked by this user!" if user.id == params[:user_id]
		end
	end

end
