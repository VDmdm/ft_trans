class TournamentStartJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    tournament = Tournament.find_by(id: id)
    return if !tournament || !tournament.registration?
    if tournament.tournament_players.size != tournament.max_players
      tournament.update_attribute(:status, :no_enought_players)
      return
    end
    tournament.update_attribute(:status, :goes)
    tournament.make_pair
    TournamentRoundJob.perform_later(tournament, 0)
  end
end
