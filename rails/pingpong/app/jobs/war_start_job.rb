class WarStartJob < ApplicationJob
  queue_as :default

  def perform(id)
    war = War.find_by(id: id)
    return if !war || war.status != :wait_start
    war.update_attribute(:status, :in_war)
    WarEndJob.set(wait_until: war.ended).perform_later(war)
  end
end