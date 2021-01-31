class CreateGameRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :game_rooms do |t|
      t.references  :p1, foreign_key: { to_table: 'users' }
      t.references  :p2, foreign_key: { to_table: 'users' }
      t.string      :name
      t.integer     :status, default: 0
      t.boolean     :rating, default: false
      t.boolean     :private, default: false
      t.string      :passcode, default: ''
      t.string      :ball_color, default: "#ffffff"
      t.string      :bg_color, default: "#000000"
      t.string      :paddle_color, default: "#ffffff"
      t.float       :paddle_speed, default: 6
      t.float       :paddle_p1_dy, default: 0
      t.float       :paddle_p2_dy, default: 0
      t.float       :paddle_p1_y, default: 120
      t.float       :paddle_p2_y, default: 120
      t.boolean     :ball_down_mode, default: false
      t.boolean     :ball_speedup_mode, default: false
      t.boolean     :random_mode, default: false
      t.float       :ball_radius, default: 10
      t.float       :ball_size, default: 2
      t.float       :ball_x, default: 358
      t.float       :ball_y, default: 173
      t.float       :ball_dx, default: 2
      t.float       :ball_dy, default: -2
      t.float       :speed_rate, default: 1.0
      t.integer     :p1_score, default: 0
      t.integer     :p2_score, default: 0
      t.boolean     :war_time, default: false
      t.boolean     :resetting, default: false
      t.datetime    :started
      t.datetime    :ended
      t.timestamps
    end
  end
end
