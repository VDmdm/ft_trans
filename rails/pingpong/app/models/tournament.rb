class Tournament < ApplicationRecord
	has_many		:tournament_players
	has_many		:tournament_users, :through => :tournament_players, :source => :player
	has_many		:tournament_winners, -> { where(winner: true) }, :class_name => :TournamentPlayer
	belongs_to 		:creator, class_name: :User, foreign_key: "creator_id"

end
