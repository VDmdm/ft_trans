class RoomsController < ApplicationController
	before_action :load_rooms

	def index
		@rooms = Room.all
	end

	def new
		@room = Room.new
	end

	def show
		@room_message = RoomMessage.new room: @room
		@room_messages = @room.room_messages.includes(:user)
	end

	def create
		@room = Room.new parameters
		
		if @room.save
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

	private
	def parameters
		params.require(:room).permit(:name, :password)
	end

	def load_rooms
		@rooms = Room.all
		@room = Room.find(params[:id]) if params[:id]
	end


end
