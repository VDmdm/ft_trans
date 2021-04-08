class TournamentPair < ApplicationRecord
	belongs_to 		:p1, class_name: :User, foreign_key: "p1_id"
	belongs_to 		:p2, class_name: :User, foreign_key: "p2_id"
	belongs_to 		:tournament, class_name: :Tournament, foreign_key: "tournament_id", dependent: :destroy
	belongs_to 		:game, class_name: :Game, foreign_key: "game_id", optional: true
end
