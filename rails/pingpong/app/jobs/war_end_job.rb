class WarEndJob < ApplicationJob
  queue_as :default

  def perform(id)
    war = War.find_by(id: id)
    return if war.status == :finish
    war.status = :finish
    if war.initiator_score > war.recipient_score
      war.winner_id = war.initiator
      war.initiator.update_attribute(:points, war.initiator.points + war.prize)
    elsif war.initiator_score == war.recipient_score
      war.initiator.update_attribute(:points, war.initiator.points + war.prize / 2)
      war.recipient.update_attribute(:points, war.recipient.points + war.prize / 2)
      war.status = :finish_draw
    else
      war.winner_id = war.recipient
      war.recipient.update_attribute(:points, war.recipient.points + war.prize)
    end
    war.save
  end
end
