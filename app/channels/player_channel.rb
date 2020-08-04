require "json"

class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def get_games
    games = Game.where(has_started: false, game_ended: false)
    games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
    ActionCable.server.broadcast "player_#{uuid}", {games: games_json}
  end

  def create_game(data)
    player = Player.find_by(uuid: uuid)
    player.nickname = data["nickname"]
    player.save
    if data["total_players_num"].to_i < 2
      ActionCable.server.broadcast "player_#{uuid}", {error: "Enter an integer more than 1 for Minimum Players"}
    else
      game = Game.new(name: data["game_name"], started_by: player, total_players_num: data["total_players_num"],
                      has_started: false, winner_found: false, game_ended: false)
      if game.save
        ActionCable.server.broadcast "player_#{uuid}", {game_id: game.id, nickname: data["nickname"]}
      else
        ActionCable.server.broadcast "player_#{uuid}", {error: "Game could not be saved"}
      end
    end
  end
end
