require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "Game can be created and modified" do
    player = Player.new(nickname:'Sailesh', uuid: 'f5746f54-d488-4389-85f8-7e89f271fcde')
    assert player.save, "Player could not be saved"
    game = Game.new(name: "Sailesh", started_by: player, total_players_num: 10,
                    has_started: false, winner_found: false, game_ended: false)
    assert game.save, "Game could not be saved"
    assert_equal game.started_by.nickname, player.nickname, "Game and Player relationship is not working"
    game.players << player
    assert game.save, "Player couldn't join the game"
    assert_equal game.players.first.nickname, player.nickname, "Game and Player relationship is not working"
    game.has_started = true
    assert game.save, "Game couldn't be started"
    game.players.delete(player)
    assert game.save, "Game couldn't be saved after removing player"
    assert_equal game.players.empty?, true, "Player couldn't be removed"
    trivium = Trivium.new(text:'Who discovered gravity?', correct_answer:'Newton',
                          choice1:'Einstein', choice2:'Newton')
    assert trivium.save, "Trivium could not be saved"
    question = Question.new(position: 1, trivium: trivium, expires_at: Time.now + 10.seconds,
                            choice1_num: 0, choice2_num: 0, choice3_num: 0, choice4_num: 0,
                          winner_found: false)
    assert question.save, "Question could not be saved"
    assert_equal question.trivium.text, trivium.text, "Question and Trivium relationship is not working"
    game.questions << question
    assert game.save, "Question couldn't be added to game"
    assert_equal game.questions.first.trivium.text, question.trivium.text, "Game and Question relationship is not working"
  end
end
