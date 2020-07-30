require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "Player can be created" do
    player = Player.new(nickname:'Sailesh', uuid: 'f5746f54-d488-4389-85f8-7e89f271fcde')
    assert player.save, "Player could not be saved"
  end
end
