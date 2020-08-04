class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}"
    game = Game.find_by(id: params[:game_id])
    if game.has_started
      ActionCable.server.broadcast "player_#{uuid}", {error: "Game could not be joined"}
      reject
    else
      game = Game.find_by(id: params[:game_id])
      player = Player.find_by(uuid: uuid)
      player.nickname = params[:nickname]
      player.save
      if !(game.players.exists?(player.id))
        game.players << player
        game.save
        if game.players.length === game.total_players_num
          game.has_started = true
          game.save
          games = Game.where(has_started: false, game_ended: false)
          games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                                  :players => {:only => [:nickname]}}))
          ActionCable.server.broadcast "active_games", {games: games_json}
          position = 1
          while Game.find_by(id:game.id, game_ended:false)
            trivium = Trivium.offset(rand(Trivium.count)).first
            question = Question.new(position: position,
                                    trivium: trivium,
                                    expires_at: Time.now + 30.seconds,
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
            sleep(question.expires_at - Time.now)
            game = Game.find_by(id: game.id)
            if game.players.length <= 1
              game.game_ended = true
            end
            game.save
            question = Question.find_by(id: question.id)
            trivium = question.trivium
            question_json = JSON.parse(question.to_json(:include => :trivium))
            game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                                  :players => {:only => [:nickname]}}))

            for player in game.players
              if !question.choice1.find_by(player: player) && !question.choice2.find_by(player: player) && !question.choice3.find_by(player: player) && !question.choice4.find_by(player: player)
                ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'eliminated', question: question_json, game: game_json}
              else
                if question.choice1.find_by(player: player)
                  answer = trivium.choice1
                elsif question.choice2.find_by(player: player)
                  answer = trivium.choice2
                elsif question.choice3.find_by(player: player)
                  answer = trivium.choice3
                elsif question.choice4.find_by(player: player)
                  answer = trivium.choice4
                end
                if answer == trivium.correct_answer && game.players.length == 1
                  game.winner = player
                  game.save
                  ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
                elsif answer == trivium.correct_answer
                  ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'progressed', question: question_json, game: game_json}
                else
                  ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'eliminated', question: question_json, game: game_json}
                end
              end
            end
            sleep(question.expires_at - Time.now + 10.seconds)
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
  end

  def unsubscribed
    player = Player.find_by(uuid: uuid)
    game = Game.find_by(id: params[:game_id])
    if (game.players.exists?(player.id))
      game.players.destroy(player)
      game.save()
      if game.has_started == false && game.players.length > 0
        games = Game.where(has_started: false, game_ended: false)
        games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                                :players => {:only => [:nickname]}}))
        ActionCable.server.broadcast "active_games", {games: games_json}

        game_json = JSON.parse(game.to_json(:include => {:started_by => {:only => [:nickname]},
                                                :players => {:only => [:nickname]}}))
        ActionCable.server.broadcast "game_#{game.id}", {status: 'waiting', game: game_json}
      elsif game.has_started && game.players.length == 1
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
        if trivium.correct_answer == trivium.choice1 && question.choice1.find_by(player: player)
          ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
        elsif trivium.correct_answer == trivium.choice2 && question.choice2.find_by(player: player)
          ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
        elsif trivium.correct_answer == trivium.choice3 && question.choice3.find_by(player: player)
          ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
        elsif trivium.correct_answer == trivium.choice4 && question.choice4.find_by(player: player)
          ActionCable.server.broadcast "player_#{player.uuid}", {status: 'result', result: 'won', nickname: player.nickname, question: question_json, game: game_json}
        end
      end
      if game.players.length == 0
        game.game_ended = true
        game.save
        stop_all_streams
        games = Game.where(has_started: false, game_ended: false)
        games_json = JSON.parse(games.to_json(:include => {:started_by => {:only => [:nickname]},
                                                :players => {:only => [:nickname]}}))
        ActionCable.server.broadcast "active_games", {games: games_json}
      end
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
        choice1.save
        question.choice1 << choice1
        question.choice1_num += 1
      elsif answer == trivium.choice2
        choice2 = Choice2.new(question: question, player: player)
        choice2.save
        question.choice2 << choice2
        question.choice2_num += 1
      elsif answer == trivium.choice3
        choice3 = Choice3.new(question: question, player: player)
        choice3.save
        question.choice3 << choice3
        question.choice3_num += 1
      elsif answer == trivium.choice4
        choice4 = Choice4.new(question: question, player: player)
        choice4.save
        question.choice4 << choice4
        question.choice4_num += 1
      end
      question.save
    end
  end
end
