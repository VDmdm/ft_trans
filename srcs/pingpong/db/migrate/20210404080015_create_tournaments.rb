class CreateTournaments < ActiveRecord::Migration[6.1]
  def change
    create_table :tournaments do |t|
      t.references        :creator
      t.string            :name
      t.string            :description
      t.integer           :status, default: 0
      t.datetime          :start
      t.integer           :one_round_time
      t.integer           :max_players
      t.integer           :cost
      t.integer           :prize
      t.string            :ball_color, default: "#ffffff"
      t.string            :bg_color, default: "#000000"
      t.string            :paddle_color, default: "#ffffff"
      t.boolean           :ball_down_mode, default: false
      t.boolean           :ball_speedup_mode, default: false
      t.boolean           :random_mode, default: false
      t.float             :ball_size, default: 1.0
      t.float             :speed_rate, default: 1.0
      t.timestamps
    end
  end
end
