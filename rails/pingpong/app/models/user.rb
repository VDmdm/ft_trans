class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	
	validates :nickname, presence: true, uniqueness: true

	has_many :invitations
	has_many :pending_invitations, -> { where confirmed: false }, class_name: "Invitation", foreign_key: "friend_id"
  
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
	  end
	end
  
	def self.search(search)
	  if search
		where('email LIKE ?', "%#{search}%")
	  else
		User.all
	  end
	end
  
  end
  
  