require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test "Question can be created and modified" do
    player = Player.new(nickname:'Sailesh', uuid: 'f5746f54-d488-4389-85f8-7e89f271fcde')
    assert player.save, "Player could not be saved"
    trivium = Trivium.new(text:'Who discovered gravity?', correct_answer:'Newton',
                          choice1:'Einstein', choice2:'Newton')
    assert trivium.save, "Trivium could not be saved"
    question = Question.new(position: 1, trivium: trivium, expires_at: Time.now + 10.seconds,
                            choice1_num: 0, choice2_num: 0, choice3_num: 0, choice4_num: 0,
                          winner_found: false)
    assert question.save, "Question could not be saved"
    choice1 = Choice1.new(player:player, question:question)
    assert choice1.save, "Choice1 could not be modified"
    question.choice1 << choice1
    assert question.save, "Question could not be modified"
    assert_equal question.choice1.first.player.nickname, player.nickname, "Question and Choice1 relationship is not working"
    assert_equal question.trivium.text, trivium.text, "Question and Trivium relationship is not working"
  end
end
