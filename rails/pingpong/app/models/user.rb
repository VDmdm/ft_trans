class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	require 'open-uri'
	enum status: [ :offline, :online, :in_game ]

	after_create :check_user_avatar

	has_many :notifications, foreign_key: :recipient_id

	has_one :guild_member
	delegate :guild, to: :guild_member, allow_nil: true
	delegate :owner, to: :guild_member, prefix: :guild, allow_nil: true
	delegate :officer, to: :guild_member, prefix: :guild, allow_nil: true

	has_many :guild_invites, :dependent => :delete_all
	# Pending sending invites
	has_many :pending_join_requests, -> { where(status: :pending, dir: :join_request) }, :class_name => :GuildInvite
	has_many :pending_join_requests_guild, :through => :pending_join_requests, :source => :guild
	# Pending incoming invites
	has_many :pending_invites, -> { where(status: :pending, dir: :invite) }, :class_name => :GuildInvite
	has_many :pending_invites_guild, :through => :pending_invites, :source => :guild
	# accepted invites
	has_many :accepted_invites, -> { where(status: :accept) }, :class_name => :GuildInvite
	has_many :accepted_invites_guild, :through => :accepted_invites, :source => :guild
	# declined invites
	has_many :declined_invites, -> { where(status: :decline) }, :class_name => :GuildInvite
	has_many :declined_invites_guild, :through => :declined_invites, :source => :guild

	has_one_attached :avatar
	validates :avatar, attached: true, allow_blank: true, content_type: [:png, :jpg, :jpeg, :gif],
									size: { less_than: 10.megabytes , message: 'filesize to big' }

	validates :nickname, presence: true, uniqueness: true

	has_many :chat_room_members
	has_many :rooms, :through => :chat_room_members, :source => :room

	has_many :blocked_users
	has_many :invitations
	has_many :pending_invitations, -> { where confirmed: false }, class_name: "Invitation", foreign_key: "friend_id"


	has_many :games
  	has_one :pending_games_p1, -> { where(status: :pending) }, :class_name => :Game, foreign_key: "p1_id"
  	has_one :pending_games_p2, -> { where(status: :pending) }, :class_name => :Game, foreign_key: "p2_id"
  	has_many :win_games, :class_name => :Game, foreign_key: "winner_id"
  	has_many :lose_games, :class_name => :Game, foreign_key: "loser_id"

	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable,
	:omniauthable, omniauth_providers: [:marvin]


	def friends
		friends_user_sent_inv = Invitation.where(user_id: id, confirmed: true).pluck(:friend_id)
		friends_user_got_inv = Invitation.where(friend_id: id, confirmed: true).pluck(:user_id)
		ids = friends_user_sent_inv + friends_user_got_inv
		User.where(id: ids)
	end

	def direct_rooms
		rooms_where_user = DirectRoom.where(user_id: id).pluck(:id)
		rooms_where_dude = DirectRoom.where(dude_id: id).pluck(:id)
		ids = rooms_where_user + rooms_where_dude
		DirectRoom.where(id: ids)
	end
	# def rooms
	# 	usr_rooms = ChatRoomMember.where(user_id: id).pluck(:room_id)
	# 	Room.where(id: usr_rooms)
	# end
	
  
	def friends_with?(user)
	  Invitation.confirmed_record?(id, user.id)
	end

	def blocked_by
		blck = BlockedUser.where(blocked_id: id).pluck(:user_id)
		User.where(id: blck)
	end

	def blocked
		blck = BlockedUser.where(user_id: id).pluck(:blocked_id)
		User.where(id: blck)
	end

	def is_blocked?(user)
		!BlockedUser.where(user_id: id,  blocked_id: user.id).empty?
	end
  
	def send_friend_invite(user)
	  invitations.create(friend_id: user.id)
	end
  
	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email = auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.nickname = auth.info.nickname
			user.image =  auth.info.image
			downloaded_image = open(auth.info.image)
			user.avatar.attach(io: downloaded_image, filename: 'avatar.jpg', content_type: downloaded_image.content_type)
		end
	end
  
	def self.search(search)
		if search
			where('nickname LIKE ?', "%#{search}%")
		else
			User.all
		end
	end

	def rating
		User.order(score: :desc).index(self) + 1
	end

	def online?
		self.status == "online" || self.status == "in_game"
	end

	def all_games
		Game.where("(p1_id = ? OR p2_id = ?)", self.id, self.id)
	end

	def pending_games
		Game.where("(p1_id = ? OR p2_id = ?) AND game_type BETWEEN 0 AND 2 AND status = 0", self.id, self.id)
	end

	def ended_games
		Game.where("(p1_id = ? OR p2_id = ?) AND status = 1", self.id, self.id)
	end

	def wartime_games
		Game.where("(p1_id = ? OR p2_id = ?) AND game_type = 3", self.id, self.id)
	end

	def active_wartime_games
		Game.where("(p1_id = ? OR p2_id = ?) AND game_type = 3 AND status = 0", self.id, self.id)
	end

	def tournament_games
		Game.where("(p1_id = ? OR p2_id = ?) AND game_type = 4", self.id, self.id)
	end

	def active_tournament_games
		Game.where("(p1_id = ? OR p2_id = ?) AND game_type = 4 AND status = 0", self.id, self.id)
	end

	private 

	def check_user_avatar
		unless self.avatar.attached?
			files = Dir["app/assets/images/default_avatars/*.png"]
			downloaded_image = File.open(files[rand(0..38)], 'rb')
			self.avatar.attach(io: downloaded_image, filename: 'avatar.jpg')
			self.save
		end
	end
end
