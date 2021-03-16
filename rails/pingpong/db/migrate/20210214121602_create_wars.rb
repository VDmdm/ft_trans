class CreateWars < ActiveRecord::Migration[6.1]
  def change
    create_table :wars do |t|
      t.references  :initiator
      t.references  :recipient
      t.references  :winner
      t.datetime    :started
      t.datetime    :ended
      t.time        :daily_start
      t.time        :daily_end
      t.integer     :time_to_wait
      t.integer     :max_unanswered
      t.integer     :initiator_score, default: 0
      t.integer     :recipient_score, default: 0
      t.integer     :prize
      t.integer     :status, default: 0
      t.boolean     :ball_down_mode, default: false
      t.boolean     :ball_speedup_mode, default: false
      t.boolean     :random_mode, default: false
      t.float       :ball_size, default: 1.0
      t.float       :speed_rate, default: 1.0
      t.timestamps
    end
  end
end
