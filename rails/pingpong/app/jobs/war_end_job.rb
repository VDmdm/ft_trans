class WarEndJob < ApplicationJob
  queue_as :default

  def perform(war)
    war.reload
    return if war.status == :finish
    war.status = :finish
    if war.initiator_score > war.recipient_score
      war.winner_id = war.initiator
      war.initiator.update_attribute(score, war.initiator.score + war.prize)
    elsif war.initiator_score == war.recipient_score
      war.initiator.update_attribute(score, war.initiator.score + war.prize / 2)
      war.recipient.update_attribute(score, war.recipient.score + war.prize / 2)
      war.status = :finish_draw
    else
      war.winner_id = war.recipient
      war.recipient.update_attribute(score, war.recipient.score + war.prize)
    end
    war.save
  end
end
