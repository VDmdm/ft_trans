class GameRoomsController < ApplicationController
	def index
		@game_rooms = GameRoom.all
	end

	def new
		@game_room = GameRoom.new
	end

	def create
		game_room = GameRoom.new(game_room_params)
	end

	private
	def game_room_params
		params.require(:game_rooms).permit(:name, :private, :rating, :passcode, :bg_color,
											:paddle_color, :ball_color, :ball_down_mode, 
											:ball_speedup_mode, :random_mode, :ball_size,
											:speed_rate, :bg_image);
	end
end
