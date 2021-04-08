class TournamentEndJob < ApplicationJob
  queue_as :default

  def perform(tournament)
    # Do something later
    tournament.update_attribute(:status, :completed)
    max_score = tournament.tournament_players.maximum(:score)
    return if max_score <= 0
    winners = tournament.tournament_players.where("score = ?", max_score)
    players = winners.size
    winners.each do |winner|
      winner.update_attribute(:winner, true)
      winner.player.update_attribute(:score, winner.player.score + (tournament.prize / players))
    end
  end
end