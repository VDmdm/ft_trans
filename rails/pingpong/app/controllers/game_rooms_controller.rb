class GameRoomsController < ApplicationController

	before_action :check_game_room_not_exist, only: [:show]
	before_action :check_user_pending_game_exist, only: [:create]

	def index
		@game_rooms = GameRoom.all
	end

	def new
		@game_room = GameRoom.new
	end

	def create
		game_room = GameRoom.new(game_room_params)
		game_room.p1 = current_user
		if game_room.save
			redirect_to game_room_path(game_room), success: "Game was created!"
		else
			redirect_to new_game_room_path, alert: game_room.errors.full_messages.join("; ")
		end
	end

	def show
		@game_room = GameRoom.find(params[:id])
	end

	private
	def game_room_params
		params.require(:game_room).permit(	:name, :private, :rating, :passcode, :bg_color,
											:paddle_color, :ball_color, :ball_down_mode, 
											:ball_speedup_mode, :random_mode, :ball_size,
											:speed_rate, :bg_image );
	end

	def check_game_room_not_exist
		game_room = GameRoom.find_by(id: params[:id])
		redirect_to game_rooms_path, alert: "Game not found!" unless game_room
	end

	def check_user_pending_game_exist
		redirect_to game_rooms_path, alert: "You allready have a game" if current_user.pending_games?
	end
end
