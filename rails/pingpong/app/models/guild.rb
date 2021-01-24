class Guild < ApplicationRecord
	validates :name, presence: true, uniqueness: true, length: { maximum: 15 }
	validates :anagram, presence: true, uniqueness: true, length: { is: 5 }
	validates :description, length: { maximum: 100 }

end
