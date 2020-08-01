module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.urlsafe_base64
      player = Player.new(uuid: self.uuid)
      player.save
    end
  end
end
