class GameChannel < ApplicationCable::Channel
	def subscribed
		game = Game.find(params[:game])
		stream_for game
		if (game.p1 == current_user || game.p2 == current_user) && !game.broadcasted
			game.update_attribute(:broadcasted, true)
			GameLoopJob.new(game.id).perform_now()
		end
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
		game = Game.where("(p1_id = ? OR p2_id = ?) AND status = 1", current_user.id, current_user.id)
		if game && game.p1 == current_user
			status = "p1"
		elsif game && game.p2 == current_user
			status = "p2"
		end
		if GameStateHash.instance.return_value("#{status}_status_#{game.id}") == "ready" &&
			game.status != "ended"
			GameStateHash.instance.add_kv("#{status}_status_#{game.id}", "lags")
			GameStateHash.instance.add_kv("#{status}_lagtime_#{game.id}", DateTime.now)
		end
	end
end
