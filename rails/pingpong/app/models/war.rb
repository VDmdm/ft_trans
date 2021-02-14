class War < ApplicationRecord
    enum status: [ :send_request, :wait_start, :in_war, :finish ]

    belongs_to :initiator, class_name: :Guild, foreign_key: "initiator_id"
    belongs_to :recipient, class_name: :Guild, foreign_key: "recipient_id"
    has_one    :winner_id, class_name: :Guild, foreign_key: "winner_id", required: false

    has_many   :war_times
    has_one    :waiting_wt, -> { where(status: :wait_players) }, :class_name => :WarTimes
    has_one    :active_wt, -> { where(status: :game_active) }, :class_name => :WarTimes
    has_many   :ended_wt, -> { where(status: :game_ended) }, :class_name => :WarTimes

    validates  :ball_size, :inclusion => 0.5..2.0
    validates  :speed_rate, :inclusion => 0.5..2.0
    validates  :random_mode, presence: true, allow_blank: true

    private
    def in_wt?
        self.active_wt || self.waiting_wt
    end
end