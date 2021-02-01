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
	has_many :pending_sending_invites, -> { where(status: :pending, dir: :incoming) }, :class_name => :GuildInvite
	has_many :pending_sending_invites_guild, :through => :pending_sending_invites, :source => :guild
	# Pending incoming invites
	has_many :pending_incoming_invites, -> { where(status: :pending, dir: :sending) }, :class_name => :GuildInvite
	has_many :pending_incoming_invites_guild, :through => :pending_incoming_invites, :source => :guild
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

	has_many :invitations
	has_many :pending_invitations, -> { where confirmed: false }, class_name: "Invitation", foreign_key: "friend_id"

	has_many :game
  	has_one :pending_games_p1, -> { where(status: :pending, war_time: false) }, :class_name => :Game, foreign_key: "p1_id"
  	has_one :pending_games_p2, -> { where(status: :pending, war_time: false) }, :class_name => :Game, foreign_key: "p2_id"

	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable,
	:omniauthable, omniauth_providers: [:marvin]
  
	def friends
		friends_user_sent_inv = Invitation.where(user_id: id, confirmed: true).pluck(:friend_id)
		friends_user_got_inv = Invitation.where(friend_id: id, confirmed: true).pluck(:user_id)
		ids = friends_user_sent_inv + friends_user_got_inv
		User.where(id: ids)
	end
  
	def friends_with?(user)
	  Invitation.confirmed_record?(id, user.id)
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
			where('email LIKE ?', "%#{search}%")
		else
			User.all
		end
	end

	def rating
		User.order(:score).index(self) + 1
	end

	def online?
		self.status == "online" || self.status == "in_game"
	end

	def pending_games?
		self.pending_games_p1 || self.pending_games_p2
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
