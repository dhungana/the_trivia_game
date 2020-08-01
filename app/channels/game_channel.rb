class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])
    game.players << player
    game.save()
    if game.players.length === game.total_players_num
      game.has_started = true
      game.save()
      ## TODO: Start game
    else
      games = Game.where(has_started: false, game_ended: false)
      games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                              :players => {:only => [:nickname]}}))
      ActionCable.server.broadcast "active_games", {games: games_json}
    end
  end

  def unsubscribed
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])
    game.players.destroy(player)
    if game.players.length == 0
      game.game_ended = true
    end
    game.save()
    games = Game.where(has_started: false, game_ended: false)
    games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
    ActionCable.server.broadcast "active_games", {games: games_json}
  end
end
