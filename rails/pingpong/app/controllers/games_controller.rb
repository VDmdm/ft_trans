class GamesController < ApplicationController

	before_action :check_game_not_exist, only: [:show, :join_player]
	before_action :check_user_pending_game_exist, only: [:create, :join_player]
	before_action :check_game_is_ended, only: [:show, :join_player, :leave_games]
	before_action :check_game_allready_have_p2, only: [:join_player]
	before_action :check_passcode_wrong, only: [:join_player]
	before_action :check_game_not_wartime, only: [:join_player]
	before_action :check_current_user_not_in_guild, only: [:wartime_game_create]
	before_action :check_p2_not_exist, only: [:wartime_game_create]
	before_action :check_p2_guild_not_exist, only: [:wartime_game_create]
	before_action :check_players_in_same_guild, only: [:wartime_game_create]
	before_action :check_war_is_active, only: [:wartime_game_create]
	before_action :check_wartime_is_active, only: [:wartime_game_create]
	before_action :check_wartime_game_not_exist, only: [:wartime_game_create]

	def index
		@games = Game.all
		if current_user.guild
			@war_active = current_user.guild.war_active
		end
	end

	def new
		@game = Game.new
	end

	def create
		game = Game.new(game_params)
		game.p1 = current_user
		if game.save
			GameStateHash.instance.add_kv("p1_status_#{game.id}", "not ready")
			GameStateHash.instance.add_kv("status_#{game.id}", "waiting")
			GameStateHash.instance.add_kv("p1_nickname_#{game.id}", game.p1.nickname)
			GameStateHash.instance.add_kv("p1_pause_#{game.id}", "false")
			GameStateHash.instance.add_kv("p2_pause_#{game.id}", "false")
			redirect_to game_path(game), success: "Game was created!"
		else
			redirect_to new_game_path, alert: game.errors.full_messages.join("; ")
		end
	end

	def wartime_game_create
		p1 = current_user
		p2 = User.find_by(id: params[:p2_id])
		war = current_user.guild.war_active
		game = Game.new name: "war_time: #{p1.guild.name} - #{p2.guild.name}",
						p1: p1,
						p2: p2,
						game_type: 'wartime',
						ball_down_mode: war.ball_down_mode,
						ball_speedup_mode: war.ball_speedup_mode,
						random_mode: war.random_mode,
						ball_size: war.ball_size,
						speed_rate: war.speed_rate
		if game.save
			GameStateHash.instance.add_kv("p1_status_#{game.id}", "not ready")
			GameStateHash.instance.add_kv("p1_nickname_#{game.id}", p1.nickname)
			GameStateHash.instance.add_kv("p2_status_#{game.id}", "not ready")
			GameStateHash.instance.add_kv("p2_nickname_#{game.id}", p2.nickname)
			GameStateHash.instance.add_kv("status_#{game.id}", "waiting")
			GameStateHash.instance.add_kv("p2_activate_game_#{game.id}", "no")
			GameStateHash.instance.add_kv("p1_pause_#{game.id}", "false")
			GameStateHash.instance.add_kv("p2_pause_#{game.id}", "false")
			wartime = Wartime.new 		war: war,
										game: game,
										guild_1: war.initiator,
										guild_2: war.recipient
			wartime.save
			redirect_to game_path(game), success: "Game was created!"
		else
			redirect_to games_path, alert: game.errors.full_messages.join("; ")
		end
	end

	def show
		@game = Game.find(params[:id])
		if @game.p2 == current_user
			GameStateHash.instance.add_kv("p2_activate_game_#{@game.id}", "yes")
		end
	end

	def join_player
		game = Game.find(params[:id])
        game.p2 = current_user
        unless game.save
            redirect_to games_path, alert: game.errors.full_messages.join("; ")
        else
			GameStateHash.instance.add_kv("p2_status_#{game.id}", "not ready")
			GameStateHash.instance.add_kv("p2_nickname_#{game.id}", game.p2.nickname)
			redirect_to game_path(game), success: "success!"
        end
	end

	def leave_player
		game = Game.find(params[:id])
		p GameStateHash.instance.return_value("status_#{game.id}")
		if current_user == game.p1
			if GameStateHash.instance.return_value("status_#{game.id}") == 'waiting'
            	game.destroy
				GameStateHash.instance.add_kv("status_#{game.id}", "canceled")
				redirect_to games_path, notice: "Game has been destroyed!"
			else
				GameStateHash.instance.add_kv("p1_status_#{game.id}", "leave")
				redirect_to game_path(game), success: "You leave!"
			end
		elsif current_user == game.p2
			if (GameStateHash.instance.return_value("status_#{game.id}") == 'waiting')
				GameStateHash.instance.delete("p2_nickname_#{game.id}")
				GameStateHash.instance.delete("p2_status_#{game.id}")
				game.p2 = nil
				game.save
			else
				GameStateHash.instance.add_kv("p2_status_#{game.id}", "leave")
			end
			redirect_to game_path(game), success: "You leave!"
        end
	end

	def switch_ready
		game = Game.find(params[:id])
		if current_user == game.p1
			string = "p1"
		else
			string = "p2"
		end
		status = GameStateHash.instance.return_value("#{string}_status_#{game.id}")
		if status == "not ready" || status == "lags"
			GameStateHash.instance.add_kv("#{string}_status_#{game.id}", "ready")
		elsif status == "ready"
			p "=================== #{GameStateHash.instance.return_value("#{string}_pause_#{game.id}")} ===================="
			if GameStateHash.instance.return_value("#{string}_pause_#{game.id}") == "false"
				GameStateHash.instance.add_kv("#{string}_status_#{game.id}", "not ready")
			end
			if GameStateHash.instance.return_value("status_#{game.id}") == 'active' && GameStateHash.instance.return_value("#{string}_pause_#{game.id}") == "false"
				GameStateHash.instance.add_kv("#{string}_pause_#{game.id}", "true")
				GameStateHash.instance.add_kv("pause_time_#{game.id}", DateTime.now)
			end
		end
		if GameStateHash.instance.return_value("p1_status_#{game.id}") == "ready" &&
			GameStateHash.instance.return_value("p2_status_#{game.id}") == "ready"
			GameStateHash.instance.add_kv("status_#{game.id}", "active")
		end
	end

	private
	def game_params
		params.require(:game).permit(	:name, :game_type, :passcode, :bg_color,
										:paddle_color, :ball_color, :ball_down_mode,
										:ball_speedup_mode, :random_mode, :ball_size,
										:speed_rate, :bg_image )
	end

	def check_game_not_exist
		game = Game.find_by(id: params[:id])
		redirect_to games_path, alert: "Game not found!" unless game
	end

	def check_user_pending_game_exist
		redirect_to games_path, alert: "You allready have a game" unless current_user.pending_games.empty?
	end

	def check_game_is_ended
		game = Game.find_by(id: params[:id])
		redirect_to games_path, alert: "Game has been ended!" if game.status == "ended"
	end

	def check_game_allready_have_p2
		game = Game.find_by(id: params[:id])
		redirect_to game_path(game), alert: "Game is full" if game.p2
	end

	def check_passcode_wrong
		game = Game.find_by(id: params[:id])
		redirect_to game_path(game), alert: "Wrong passcode" if game.close? &&
												game.passcode != params[:passcode]
	end

	def check_current_user_not_in_guild
		redirect_to games_path, alert: "You not in guild" unless current_user.guild
	end

	def check_p2_not_exist
		p2 = User.find_by(id: params[:p2_id])
		redirect_to games_path, alert: "User not exist" unless p2
	end

	def check_p2_guild_not_exist
		p2 = User.find_by(id: params[:p2_id])
		redirect_to games_path, alert: "Wrong user" unless p2.guild
	end

	def check_players_in_same_guild
		p1 = current_user
		p2 = User.find_by(id: params[:p2_id])
		redirect_to games_path, alert: "Players can't be in same guild" if p1.guild == p2.guild
	end

	def check_war_is_active
		p1 = current_user
		p2 = User.find_by(id: params[:p2_id])
		redirect_to games_path, alert: "Players guilds not in active war" unless p1.guild.in_war?(p2.guild)
	end

	def check_wartime_is_active
		war = current_user.guild.war_active
		redirect_to games_path, alert: "Wartime is not active now" unless war.wartime_active?
	end

	def check_wartime_game_not_exist
		war = current_user.guild.war_active
		redirect_to games_path, alert: "Wartime game allready started between guilds" if war.active_wartime
	end
	
	def check_game_not_wartime
		game = Game.find_by(id: params[:id])
		redirect_to games_path(params[:id]), alert: "You can't leave from wartime games" if game.wartime?
	end
end
