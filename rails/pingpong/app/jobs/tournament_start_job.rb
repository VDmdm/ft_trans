class TournamentStartJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    tournament = Tournament.find_by(id: id)
    return unless tournament
    
  end
end
