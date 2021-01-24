class GuildMember < ApplicationRecord
  belongs_to :guild
  belongs_to :user
end
