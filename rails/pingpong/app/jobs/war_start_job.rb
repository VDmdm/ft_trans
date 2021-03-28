class WarStartJob < ApplicationJob
  queue_as :default

  def perform(id)
    war = War.find_by(id: id)
    return unless war
    return war.update_attribute(:status, :declined) if war.status != "wait_start"
    war.update_attribute(:status, :in_war)
    WarEndJob.set(wait_until: war.ended).perform_later(war)
  end
end