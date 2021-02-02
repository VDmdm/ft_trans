class RoomsController < ApplicationController
	before_action :load_rooms

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
		if @room.update_attributes(parameters)
			redirect_to rooms_path, success: "Room was updated"
		else
			render :new
		end
	end

	def password_enter
		p params[:password]
		if params[:password] != @room.password
			redirect_to rooms_path, alert: "Password is incorrect"
		else
			redirect_to chat_room_members_new_path(room_id: @room)
		end
	end

	private
	def parameters
		params.require(:room).permit(:name, :password)
	end

	def load_rooms
		@rooms = Room.all
		@room = Room.find(params[:id]) if params[:id]
		@room_member = ChatRoomMember.new
	end


end
