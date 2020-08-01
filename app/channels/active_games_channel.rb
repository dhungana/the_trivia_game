class ActiveGamesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "active_games"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
