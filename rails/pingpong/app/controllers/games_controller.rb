class GamesController < ApplicationController

	before_action :check_game_not_exist, only: [:show]
	before_action :check_user_pending_game_exist, only: [:create]

	def index
		@games = Game.all
	end

	def new
		@game = Game.new
	end

	def create
		game = Game.new(game_params)
		game.p1 = current_user
		if game.save
			redirect_to game_path(game), success: "Game was created!"
		else
			redirect_to new_game_path, alert: game.errors.full_messages.join("; ")
		end
	end

	def show
		@game = Game.find(params[:id])
	end

	private
	def game_params
		params.require(:game).permit(		:name, :private, :rating, :passcode, :bg_color,
											:paddle_color, :ball_color, :ball_down_mode,
											:ball_speedup_mode, :random_mode, :ball_size,
											:speed_rate, :bg_image );
	end

	def check_game_not_exist
		game = Game.find_by(id: params[:id])
		redirect_to games_path, alert: "Game not found!" unless game
	end

	def check_user_pending_game_exist
		redirect_to games_path, alert: "You allready have a game" if current_user.pending_games?
	end
end
