import React, { useState } from "react"
import consumer from "../channels/consumer"
import "../style/app.css"
import CreateGame from './createGame'
import Games from './games'

const Heading = () => (
  <div>
    <h1>The Trivia Game </h1>
    <hr/>
  </div>
)

const App = () => {
  const [currentGame, setCurrentGame] = useState(0)
  const [gameStarted, setGameStarted] = useState(false)
  const [games, setGames] = useState([])

  const activeGamesChannel = consumer.subscriptions.create({channel: "ActiveGamesChannel"}, {
    received: function(data) {
      if ('games' in data) {
        setGames(data.games)
      }
    }
  })

  const joinGame = (game_id) => {
    consumer.subscriptions.create({channel: "GameChannel", game_id: game_id}, {
      connected: function() {
        setCurrentGame(game_id)
      },
      received: function(data) {
        if ('games' in data) {
          // setGames(data.games)
        } else if ('game_id' in data) {
          // joinGame(data['game_id'])
        }
      }
    })
  }

  const playerChannel = consumer.subscriptions.create({channel: "PlayerChannel"}, {
    connected: function() {
      playerChannel.send({action: 'get_games'})
    },
    received: function(data) {
      if ('games' in data) {
        setGames(data.games)
      } else if ('game_id' in data) {
        joinGame(data['game_id'])
      }
    }
  })

  return (
    <div>
      <Heading />
      {gameStarted === false ? <CreateGame playerChannel={playerChannel}/> : null}
      {gameStarted === false && games.length > 0 ? <Games games={games} joinGame={joinGame}/> : null}
    </div>
    )
}

export default App
