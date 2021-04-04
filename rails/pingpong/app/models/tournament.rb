class Tournament < ApplicationRecord
	has_one_attached :bg_image
	
	enum 			status: [:registration, :goes, :completed]
	belongs_to 		:creator, class_name: :User, foreign_key: "creator_id"
	has_many		:tournament_players
	has_many		:tournament_users, :through => :tournament_players, :source => :player
	has_many		:tournament_winners, -> { where(winner: true) }, :class_name => :TournamentPlayer
	
	has_many		:tournament_pair

	validates  :name, presence: true, length: { maximum: 15, minimum: 4 }
    validates  :bg_image, attached: true, content_type: [:png, :jpg, :jpeg], size: { less_than: 10.megabytes , message: 'filesize to big' }, allow_blank: true
    validates  :ball_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :bg_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :random_mode, presence: true
    validates  :paddle_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :ball_size, presence: true, :inclusion => 0.5..2.0
	validates  :speed_rate, presence: true, :inclusion => 0.5..2.0
	

	def make_pair
		@rounds = []
		rounds = self.tournament_users.size - 1
		match_per_round = self.tournament_users.size / 2
		players = self.tournament_users
		rounds.times do |index|
			@rounds[index] = []
			match_per_round.times do |match_index|
				@rounds[index] << [players[match_index], players.reverse[match_index]]
			end
			players = [players[0]] + players[1..-1].rotate(-1)
		end
		@rounds.each_with_index do |round, index|
			round.each do |pair|
				self.tournament_pair.create 	p1: pair[0],
			 									p2: pair[1],
												round: index
			end
		end
	end
end
