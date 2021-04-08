class TournamentsController < ApplicationController
	def index
		@tournaments = Tournament.all
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
			redirect_to tournament_path(tournament), success: "Tournament was created"
		else
			redirect_to tournaments_path, alert: "Can't create tournament: #{ tournament.errors.full_messages.join(", ") }"
		end
	end

	def show

	end

	def delete
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
end
