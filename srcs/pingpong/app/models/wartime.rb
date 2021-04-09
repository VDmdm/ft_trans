class Wartime < ApplicationRecord
	belongs_to :war, class_name: :War, foreign_key: "war_id"
    belongs_to :game, class_name: :Game, foreign_key: "game_id"
	belongs_to :winner, class_name: :Guild, foreign_key: "winner_id", required: false
    belongs_to :guild_1, class_name: :Guild, foreign_key: "guild_1_id"
    belongs_to :guild_2, class_name: :Guild, foreign_key: "guild_2_id"
	
end
