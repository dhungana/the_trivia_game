class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
    game = Game.find_by(id: params[:game_id])
    reject if game.has_started
    player = Player.find_by(uuid: uuid)
    player.nickname = params[:nickname]
    player.save
    ## TODO: Nickname error
    game.players << player
    game.save
    if game.players.length === game.total_players_num
      game.has_started = true
      game.save
      ## TODO: Start game
      position = 1
      while Game.where(id:game.id, game_ended:false)
        trivium = Trivium.offset(rand(Trivium.count)).first
        question = Question.new(position: position,
                                trivium: trivium,
                                expires_at: Time.now + 10.seconds,
                                choice1_num: 0,
                                choice2_num: 0,
                                choice3_num: 0,
                                choice4_num: 0,
                                winner_found: false
                              )
        question.save
        question_json = JSON.parse(question.to_json(:include => {:trivium => {:only => [:text, :choice1, :choice2, :choice3, :choice4]}}))
        position += 1
        ActionCable.server.broadcast "game_#{game.id}", {status: 'question', question: question_json}
        sleep(10.seconds)
        question_json = JSON.parse(question.to_json(:include => :trivium))
        ActionCable.server.broadcast "game_#{game.id}", {status: 'result', question: question_json}
        sleep(10.seconds)
      end
    else
      games = Game.where(has_started: false, game_ended: false)
      games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                              :players => {:only => [:nickname]}}))
      ActionCable.server.broadcast "active_games", {games: games_json}
      game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                              :players => {:only => [:nickname]}}))
      ActionCable.server.broadcast "game_#{game.id}", {status: 'waiting', game: game_json}
    end
  end

  def unsubscribed
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])
    game.players.destroy(player)
    ## TODO: Only one winner left
    if game.players.length == 0
      game.game_ended = true
    end
    game.save()
    games = Game.where(has_started: false, game_ended: false)
    games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
    ActionCable.server.broadcast "active_games", {games: games_json}
    game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
    ActionCable.server.broadcast "game_#{game.id}", {status: 'waiting', game: game_json}
  end

end
