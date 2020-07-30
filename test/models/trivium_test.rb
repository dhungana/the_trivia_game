require 'test_helper'

class TriviumTest < ActiveSupport::TestCase
  test "Trivium can be created" do
    trivium = Trivium.new(text:'Who discovered gravity?', correct_answer:'Newton',
                          choice1:'Einstein', choice2:'Newton')
    assert trivium.save, "Trivium could not be saved"
  end
end
