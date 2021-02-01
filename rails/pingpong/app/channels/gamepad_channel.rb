class GamepadChannel < ApplicationCable::Channel
	#before-subscribe :check_game_exist
	#before-subscribe :check_game_status

	def subscribed
		# stream_from "some_channel"
		game = Game.find(params[:game_room])
		if (current_user == game.p1 || current_user == game.p2)
			stream_for game
		else
			return
		end
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
	end

	def receive(data)
		id = data["game_room"]
		if current_user.pending_games_p1.id == id.to_i
			if data["pad"] > 0
				GameStateHash.instance.add_kv("paddle_p1_#{data["game_room"]}", 6)
			elsif data["pad"] == 0
				GameStateHash.instance.add_kv("paddle_p1_#{data["game_room"]}", 0)
			elsif data["pad"] < 0
				GameStateHash.instance.add_kv("paddle_p1_#{data["game_room"]}", -6)
			end
		elsif current_user.pending_games_p1.id == id.to_i
			if data["pad"] > 0
				GameStateHash.instance.add_kv("paddle_p2_#{data["game_room"]}", 6)
			elsif data["pad"] == 0
				GameStateHash.instance.add_kv("paddle_p2_#{data["game_room"]}", 0)
			elsif data["pad"] < 0
				GameStateHash.instance.add_kv("paddle_p2_#{data["game_room"]}", -6)
			end
		end
	end

	private

	def check_game_exist
		game = Game.find_by(id: params[:game_room])
		return unless game
	end

	def check_game_status
		game = Game.find(id: params[:game_room])
		return if game.status == "ended"
	end
end