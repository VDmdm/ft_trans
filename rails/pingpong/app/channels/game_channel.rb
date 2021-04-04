class GameChannel < ApplicationCable::Channel
	def subscribed
		game = Game.find(params[:game])
		stream_for game
		if game.p1 == current_user && !game.broadcasted
			game.broadcasted = true
			game.save
			GameLoopJob.new(game.id).perform_now()
		end
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
		if current_user.pending_games_p1
			game = current_user.pending_games_p1
			status = "p1"
		elsif current_user.pending_games_p2
			game = current_user.pending_games_p2
			status = "p2"
		end
		if GameStateHash.instance.return_value("#{status}_status_#{game.id}") == "ready" &&
			game.status != "ended"
			GameStateHash.instance.add_kv("#{status}_status_#{game.id}", "lags")
			GameStateHash.instance.add_kv("#{status}_lagtime_#{game.id}", DateTime.now)
		end
	end
end
