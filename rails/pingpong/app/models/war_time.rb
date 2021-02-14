class WarTime < ApplicationRecord
    enum status: [ :wait_players, :game_active, :game_ended ]
    belongs_to :war
    has_one :game
end