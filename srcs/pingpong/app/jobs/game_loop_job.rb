class GameLoopJob < ApplicationJob
	queue_as :default

	def perform(id)
		# Do something later
		game = Game.find(id)
		game.start
	end
end
