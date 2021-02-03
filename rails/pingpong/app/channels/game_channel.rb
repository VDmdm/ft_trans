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
	end
end
