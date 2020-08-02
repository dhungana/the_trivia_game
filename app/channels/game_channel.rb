class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
    game = Game.find_by(id: params[:game_id])
    reject if game.has_started
  end

  def join_game(data)
    game = Game.find_by(id: data['game_id'])
    player = Player.find_by(uuid: uuid)
    player.nickname = data['nickname']
    player.save
    if !(game.players.exists?(player.id))
      game.players << player
      game.save
      if game.players.length === game.total_players_num
        game.has_started = true
        game.save
        position = 1
        while Game.find_by(id:game.id, game_ended:false)
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
          game.questions << question
          game.save
          question_json = JSON.parse(question.to_json(:include => {:trivium => {:only => [:text, :choice1, :choice2, :choice3, :choice4]}}))
          position += 1
          ActionCable.server.broadcast "game_#{game.id}", {status: 'question', question: question_json}
          sleep(10.seconds)
          game = Game.find_by(id: game.id)
          question = Question.find_by(id: question.id)
          trivium = question.trivium
          question_json = JSON.parse(question.to_json(:include => :trivium))
          game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                                :players => {:only => [:nickname]}}))

          if !question.choice1.find_by(player: player) && !question.choice2.find_by(player: player) && !question.choice3.find_by(player: player) && !question.choice4.find_by(player: player)
            game.players.delete(player)
            game.save
            ActionCable.server.broadcast "player_#{uuid}", {status: 'result', result: 'eliminated', question: question_json, game: game_json}
          end
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
  end

  def unsubscribed
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])

    if game.has_started == false
      game.players.destroy(player)
      game.save()
      games = Game.where(has_started: false, game_ended: false)
      games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                              :players => {:only => [:nickname]}}))
      ActionCable.server.broadcast "active_games", {games: games_json}

      game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                              :players => {:only => [:nickname]}}))
      ActionCable.server.broadcast "game_#{game.id}", {status: 'waiting', game: game_json}
    elsif game.players.length == 1
      game.game_ended = true
      game.save
      player = game.players.first
      game.winner = player
      game.save
      question = game.questions.last
      trivium = question.trivium
      question_json = JSON.parse(question.to_json(:include => :trivium))
      game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
      if trivium.correct_answer == trivium.choice1 && question.choice1.where(player: player)
        ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
      elsif trivium.correct_answer == trivium.choice2 && question.choice2.find_by(player: player)
        ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
      elsif trivium.correct_answer == trivium.choice3 && question.choice3.find_by(player: player)
        ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
      elsif trivium.correct_answer == trivium.choice4 && question.choice4.find_by(player: player)
        ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
      end
    elsif game.players.length == 0
      game.game_ended = true
      game.save
      stop_all_streams
    end
  end

  def send_answer(data)
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])
    answer = data['answer']
    question = game.questions.last
    trivium = question.trivium
    if question.expires_at > Time.now
      if answer == trivium.choice1
        choice1 = Choice1.new(question: question, player: player)
        question.choice1 << choice1
        question.choice1_num += 1
      elsif answer == trivium.choice2
        choice2 = Choice2.new(question: question, player: player)
        question.choice2 << choice2
        question.choice2_num += 1
      elsif answer == trivium.choice3
        choice3 = Choice3.new(question: question, player: player)
        question.choice3 << choice3
        question.choice3_num += 1
      elsif answer == trivium.choice4
        choice4 = Choice4.new(question: question, player: player)
        question.choice4 << choice4
        question.choice4_num += 1
      end
      question.save
      if answer != trivium.correct_answer
        game.players.delete(player)
        game.save
        game = Game.find_by(id: params[:game_id])
        if game.players.length <= 1
          game.game_ended = true
        end
        game.save
      end
      sleep(question.expires_at - Time.now)
      question = Question.find_by(id: question.id)
      game = Game.find_by(id: params[:game_id])
      question_json = JSON.parse(question.to_json(:include => :trivium))
      game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                            :players => {:only => [:nickname]}}))
      if answer == trivium.correct_answer && game.players.length == 1
        game.winner = player
        game.save
        ActionCable.server.broadcast "player_#{uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
      elsif answer == trivium.correct_answer
        ActionCable.server.broadcast "player_#{uuid}", {status: 'result', result: 'progressed', question: question_json, game: game_json}
      else
        ActionCable.server.broadcast "player_#{uuid}", {status: 'result', result: 'eliminated', question: question_json, game: game_json}
      end
    end
  end
end
