class Guild < ApplicationRecord
	
	has_many :guild_members
	has_one :owner, -> { where owner: true }, class_name: "GuildMember"

	has_one_attached :avatar
	validates :avatar, attached: true, allow_blank: false, content_type: [:png, :jpg, :jpeg, :gif],
		size: { less_than: 10.megabytes , message: 'filesize to big' }

	validates :name, presence: true, uniqueness: true, length: { maximum: 15 }
	validates :anagram, presence: true, uniqueness: true, length: { is: 5 }
	validates :description, length: { maximum: 100 }

end
