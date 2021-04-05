class TournamentEndJob < ApplicationJob
  queue_as :default

  def perform(tournament)
    # Do something later
    tournament.status = :completed
    players = tournament.tournament_players.size
    max_score = tournament.tournament_players.maximum(:score)
    winners = tournament.tournament_players.where("score = ?", max_score)
    winners.each do |winner|
      winner.update_attribute(:winner, true)
      winner.player.update_attribute(:score, winner.player.score + (tournament.prize / players))
    end
  end
end
