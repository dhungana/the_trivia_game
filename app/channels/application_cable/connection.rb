module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid
      player = Player.new(uuid: self.uuid)
      player.save
    end
  end
end
