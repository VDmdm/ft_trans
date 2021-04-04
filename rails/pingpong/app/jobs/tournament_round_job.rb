class TournamentRoundJob < ApplicationJob
  queue_as :default

  def perform(tournament, round)
    # Do something later
    pairs = tournament.tournament_pair.find_by(round: round)
    if !pairs
      TournamentEndJob.perform_later(tournament)
      return
    end

    if round != 0
      pairs_previous = tournament.tournament_pair.find_by(round: round - 1)
      previous_round_continues?(pairs_previous) do
        sleep(60)
      end
    end
    
    pairs.each do |pair|
      game_create(tournament, pair)
    end
    TournamentRoundJob.set(wait_until: war.ended).perform_later(tournament, round + 1)
  end

  def game_create(tournament, pair)
    game = Game.new       name: "tournament: #{tournament.name}, round: #{pair.round} #{pair.p1.nickname} - #{pair.p2.nickname}",
                          p1: pair.p1,
                          p2: pair.p2,
                          game_type: 'tournament',
                          ball_down_mode: tournament.ball_down_mode,
                          ball_speedup_mode: tournament.ball_speedup_mode,
                          random_mode: tournament.random_mode,
                          ball_size: tournament.ball_size,
                          speed_rate: tournament.speed_rate,
                          ball_color: tournament.ball_color,
                          bg_color: tournament.bg_color,
                          paddle_color: tournament.paddle_color,
                          time_to_game: 20
    if tournament.bg_image.attached?
      game.bg_image = tournament.bg_image
    end
    game.save
    pair.update_attribute(:game, game)
  end

  def previous_round_continues?(pairs)
    pairs do |pair|
      return true if !pair.game.ended? || !pair.ended_by_time?
    end
  end
  
end
