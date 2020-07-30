require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test "Question can be created" do
    trivium = Trivium.new(text:'Who discovered gravity?', correct_answer:'Newton',
                          choice1:'Einstein', choice2:'Newton')
    assert trivium.save, "Trivium could not be saved"
    question = Question.new(position: 1, trivium: trivium, expires_at: Time.now + 10.seconds,
                            choice1_num: 0, choice2_num: 0, choice3_num: 0, choice4_num: 0,
                          winner_found: false)
    assert question.save, "Question could not be saved"
    assert_equal question.trivium.text, trivium.text, "Question and Trivium relationship is not working"
  end
end
