class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.references  :p1, foreign_key: { to_table: 'users' }
      t.references  :p2, foreign_key: { to_table: 'users' }
      t.references  :winner, foreign_key: { to_table: 'users' }
      t.references  :loser, foreign_key: { to_table: 'users' }
      t.string      :name
      t.integer     :status, default: 0
      t.integer     :game_type, default: 0
      t.string      :passcode, default: ''
      t.string      :ball_color, default: "#ffffff"
      t.string      :bg_color, default: "#000000"
      t.string      :paddle_color, default: "#ffffff"
      t.boolean     :ball_down_mode, default: false
      t.boolean     :ball_speedup_mode, default: false
      t.boolean     :random_mode, default: false
      t.float       :ball_size, default: 1.0
      t.float       :speed_rate, default: 1.0
      t.integer     :p1_score, default: 0
      t.integer     :p2_score, default: 0
      t.boolean     :resetting, default: false
      t.boolean     :broadcasted, default: false
      t.datetime    :started
      t.datetime    :ended
      t.timestamps
    end
  end
end
