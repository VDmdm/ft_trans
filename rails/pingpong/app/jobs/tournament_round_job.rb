class TournamentRoundJob < ApplicationJob
  queue_as :default

  def perform(tournament, round)
    # Do something later
    if round != 0
      pairs_previous = tournament.tournament_pair.where("round = ?", round - 1)
      while previous_round_continues?(tournament, pairs_previous) do
        sleep(60)
      end
    end
    
    pairs = tournament.tournament_pair.where("round = ?", round)
    if pairs.empty?
      TournamentEndJob.perform_later(tournament)
      return
    end
    
    pairs.each do |pair|
      game_create(tournament, pair)
    end
    TournamentRoundJob.set(wait: tournament.one_round_time.minutes).perform_later(tournament, round + 1)
  end

  def game_create(tournament, pair)
    game = Game.new       name: "tournament: #{tournament.name}, round: #{pair.round}",
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
                          time_to_game: tournament.one_round_time
    if tournament.bg_image.attached?
      game.bg_image = tournament.bg_image
    end
    game.save
    GameStateHash.instance.add_kv("p1_status_#{game.id}", "not ready")
		GameStateHash.instance.add_kv("p1_nickname_#{game.id}", pair.p1.nickname)
		GameStateHash.instance.add_kv("p2_status_#{game.id}", "not ready")
		GameStateHash.instance.add_kv("p2_nickname_#{game.id}", pair.p2.nickname)
		GameStateHash.instance.add_kv("status_#{game.id}", "waiting")
		GameStateHash.instance.add_kv("p2_activate_game_#{game.id}", "no")
		GameStateHash.instance.add_kv("p1_pause_#{game.id}", "false")
		GameStateHash.instance.add_kv("p2_pause_#{game.id}", "false")
    pair.update_attribute(:game, game)
  end

  def previous_round_continues?(tournament, pairs)
    pairs.each do |pair|
      if !pair.game.broadcasted
        player1 = tournament.tournament_players.find_by(player: pair.p1)
        player2 = tournament.tournament_players.find_by(player: pair.p2)
        player1.update_attribute(:score, player1.score - 1)
        player2.update_attribute(:score, player2.score - 1)
        pair.game.update_attribute(:status, :times_up)
      elsif pair.game.ended? || pair.game.times_up?
        next
      else
        return true
      end
    end
    return false
  end
  
end
