class GameRoom < ApplicationRecord
	has_one_attached :bg_image

	enum status: [ :pending, :ended ]
    belongs_to :p1, class_name: "User", foreign_key: "p1_id"
	belongs_to :p2, class_name: "User", foreign_key: "p2_id", optional: true

	validates  :random_mode, presence: true, allow_blank: true
    validates  :rating_game, presence: true, allow_blank: true
    validates  :private_game, presence: true, allow_blank: true
    validates  :passcode, presence: true, length: { maximum: 4, minimum: 4 }, if: :private_game?
    validates  :bg_image, attached: true, content_type: [:png, :jpg, :jpeg], size: { less_than: 10.megabytes , message: 'filesize to big' }, allow_blank: true

    validates  :ball_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :bg_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :paddle_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :ball_size, :inclusion => 0.5..2.0
    validates  :speed_rate, :inclusion => 0.5..2.0
end
