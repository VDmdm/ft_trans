class WarStartJob < ApplicationJob
  queue_as :default

  def perform(war)
    war.reload
    return if war.status == :finish
    war.update_attribute(status, :in_war)
    WarEndJob.set(wait_until: war.ended).perform_later(war)
  end
end
