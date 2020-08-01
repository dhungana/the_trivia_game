import React, { useState } from "react"
import consumer from "../channels/consumer"
import "../style/app.css"
import CreateGame from './createGame'
import Games from './games'
import WaitingRoom from './waitingRoom'
import { Button, Modal } from 'react-bootstrap'

const Heading = () => (
  <div>
    <h1>The Trivia Game </h1>
    <hr/>
  </div>
)

const App = () => {
  const [waitingRoomOpen, setWaitingRoomOpen] = useState(false)
  const [gameStarted, setGameStarted] = useState(false)
  const [games, setGames] = useState([])
  const [game, setGame] = useState({})

  const activeGamesChannel = consumer.subscriptions.create({channel: "ActiveGamesChannel"}, {
    received: function(data) {
      if ('games' in data) {
        setGames(data.games)
      }
    }
  })

  const joinGame = (game_id, nickname) => {
    consumer.subscriptions.create({channel: "GameChannel", game_id: game_id, nickname: nickname}, {
      received: function(data) {
        if ('status' in data && data['status'] == 'waiting') {
          setGame(data['game'])
          setWaitingRoomOpen(true)
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
        joinGame(data['game_id'], data['nickname'])
      } else if ('status' in data && data['status'] == 'waiting') {
        setGame(data['game'])
        setWaitingRoomOpen(true)
      }
    }
  })

  return (
    <div>
      <Heading />
      {!waitingRoomOpen && !gameStarted ? <CreateGame playerChannel={playerChannel}/> : null}
      {!waitingRoomOpen && !gameStarted && games.length > 0 ?
        <Games games={games} joinGame={joinGame}/> : null}
      {waitingRoomOpen ? <WaitingRoom game={game} /> : null}
    </div>
    )
}

export default App
