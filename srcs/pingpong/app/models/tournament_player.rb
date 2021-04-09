class TournamentPlayer < ApplicationRecord
	belongs_to 		:player, class_name: :User, foreign_key: "player_id"
	belongs_to 		:tournament, class_name: :Tournament, foreign_key: "tournament_id", dependent: :destroy
end
