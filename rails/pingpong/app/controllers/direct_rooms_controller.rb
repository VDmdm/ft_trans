class DirectRoomsController < ApplicationController
	before_action :check_user_exist, only: [:find_room]
	before_action :check_room_exist, only: [:find_room]
	before_action :check_room_exist_show, only: [:show]
	before_action :check_is_member, only: [:show]

	def show

	end

	def find_room
		@room = DirectRoom.all.find_by(user_id: current_user.id, dude_id: params[:user_id])
		@room = DirectRoom.all.find_by(user_id: params[:user_id], dude_id: current_user.id) if !@room
		redirect_to direct_rooms_path(@room)
	end

	def check_user_exist
		usr = User.all.find_by(id: params[:dude_id])
		redirect_to rooms_path, alert: "User not exist" if !usr
	end

	def check_room_exist
		case1 = DirectRoom.find_by(user_id: current_user.id, dude_id: params[:user_id])
		case2 = DirectRoom.find_by(user_id: params[:user_id], dude_id: current_user.id)
		if !case1 and !case2
			DirectRoom.create(user_id: current_user.id ,dude_id: params[:user_id])
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
end
