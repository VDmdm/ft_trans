class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,
  :omniauthable, omniauth_providers: [:marvin]
  
  include Amistad::FriendModel

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
