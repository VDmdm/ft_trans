class TournamentStartJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    tournament = Tournament.find_by(id: id)
    return if !tournament || !tournament.registration?
    tournament.make_pair
    TournamentRoundJob.perform_later(tournament, 0)
  end
end
