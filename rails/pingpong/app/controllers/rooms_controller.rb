class RoomsController < ApplicationController
	before_action :check_room_exist, only: [:show, :user_list, :room_settings, :password_enter]
	before_action :load_rooms
	before_action :check_if_member, only: [:user_list, :room_settings]
	before_action :check_if_banned, only: [:user_list, :room_settings]
	before_action :check_rights, only: [:room_settings, :update]
	
	def index
		@rooms = Room.all
	end

	def new
		@room = Room.new
	end

	def user_list
		room = Room.all.find(params[:id])
		@users = room.members
		@banned_users = room.banned_users
	end

	def show
		@room_message = RoomMessage.new room: @room
		@room_messages = @room.room_messages.includes(:user)
	end

	def create
		@room = Room.new parameters
		
		if @room.save
			@room.chat_room_members.create(user: current_user, owner: true)
			redirect_to rooms_path, success: "Room was created"
		else
			redirect_to rooms_path
		end
	end

	def update
		if @room.update(parameters)
			redirect_to rooms_path, success: "Room was updated"
		else
			render :new
		end
	end

	def room_settings

	end


	
	def load_rooms
		@rooms = Room.all
		@room = Room.find(params[:id]) if params[:id]
		@room_member = ChatRoomMember.new
		
	end

	private
	def parameters
		params.require(:room).permit(:name, :password)
	end

	def check_room_exist
		redirect_to rooms_path, alert: "Room not exist" if !Room.all.find_by(id: params[:id])
	end

	def check_if_member
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		redirect_to rooms_path, alert: "Not a member!" if !record
	end

	def check_if_banned
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		redirect_to rooms_path, alert: "banned" if record and record.banned
	end

	def check_rights
		record = ChatRoomMember.all.find_by(user_id: current_user.id, room_id: @room.id)
		redirect_to rooms_path, alert: "Don't have enough rights!" if !record.owner
	end

end
