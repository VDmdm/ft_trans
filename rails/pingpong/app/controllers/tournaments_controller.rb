class TournamentsController < ApplicationController

	before_action 	:current_is_not_admin, only: [:create, :destroy]
	before_action	:tournament_not_exist, only: [:destroy, :register, :unregister]
	before_action	:tournament_allready_started, only: [:destroy]
	before_action	:player_allready_registered, only: [:register]
	before_action	:player_not_registered, only: [:unregister]

	def index
		@tournaments = Tournament.where("status = 0")
	end

	def new
		@tournament = Tournament.new
	end

	def create
		tournament = Tournament.new tournament_parametres
		tournament.creator = current_user
		tournament.prize = tournament.cost * tournament.max_players
		if tournament.save
			TournamentStartJob.set(wait_until: tournament.start).perform_later(tournament.id)
			redirect_to tournaments_path, success: "Tournament was created"
		else
			redirect_to tournaments_path, alert: "Can't create tournament: #{tournament.errors.full_messages.join(", ")}"
		end
	end

	def destroy
		tournament = Tournament.find_by(params[:id])
		tournament.destroy
		redirect_to tournaments_path, success: "Tournament cancelled"
	end

	def register
		tournamentPlayer = TournamentPlayer.new tournament_id: params[:id],
												player: current_user
		if tournamentPlayer.save
			redirect_to tournaments_path, success: "Successefully registered!"
		else
			redirect_to tournaments_path, alert: "Registration failed: #{tournamentPlayer.errors.full_messages.join(", ")}"
		end
	end

	def unregister
		tournamentPlayer = TournamentPlayer.find_by tournament_id: params[:id],
													player: current_user
		tournamentPlayer.delete
		redirect_to tournaments_path, success: "Unregistred"
	end

	private 

	def tournament_parametres
		params.require(:tournament).permit( :creator, :name, :description, :start,
											:one_round_time, :max_players,
											:cost, :prize, :ball_color,
											:bg_color, :paddle_color, :ball_down_mode,
											:ball_speedup_mode, :random_mode, :ball_size,
											:speed_rate, :bg_image )
	end

	def current_is_not_admin
		redirect_to tournaments_path, alert: "You are not admin" unless current_user.admin
	end

	def tournament_not_exist
		tournament = Tournament.find_by(id: params[:id])
		redirect_to tournaments_path, alert: "Tournament not found" unless tournament
	end

	def tournament_allready_started
		tournament = Tournament.find_by(id: params[:id])
		redirect_to tournaments_path, alert: "Tournament registration period is over. You can't delete it." unless tournament.registration?
	end

	def player_allready_registered
		player = TournamentPlayer.find_by(tournament_id: params[:id], player: current_user)
		redirect_to tournaments_path, alert: "You are allready registred" if player
	end

	def player_not_registered
		player = TournamentPlayer.find_by(tournament_id: params[:id], player: current_user)
		redirect_to tournaments_path, alert: "You are not registred" unless player
	end
end
