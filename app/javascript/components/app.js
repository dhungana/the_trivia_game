import React, { useState } from "react"
import consumer from "../channels/consumer"
import "../style/app.css"
import CreateGame from './createGame'
import Games from './games'
import WaitingRoom from './waitingRoom'
import Question from './question'
import Result from './result'
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
  const [questionPhase, setQuestionPhase] = useState(false)
  const [resultPhase, setResultPhase] = useState(false)
  const [games, setGames] = useState([])
  const [game, setGame] = useState({})
  const [question, setQuestion] = useState({})
  const [currentAnswer, setCurrentAnswer] = useState('')
  const [gameChannel, setGameChannel] = useState(null)

  const activeGamesChannel = consumer.subscriptions.create({channel: "ActiveGamesChannel"}, {
    received: function(data) {
      if ('games' in data) {
        setGames(data.games)
      }
    }
  })

  const joinGame = (game_id, nickname) => {
    const game_channel = consumer.subscriptions.create({channel: "GameChannel", game_id: game_id, nickname: nickname}, {
      received: function(data) {
        if ('status' in data && data['status'] == 'question') {
          setQuestion(data['question'])
          setWaitingRoomOpen(false)
          setGameStarted(true)
          setQuestionPhase(true)
          setResultPhase(false)
        } else if ('status' in data && data['status'] == 'result') {
          setQuestion(data['question'])
          setWaitingRoomOpen(false)
          setGameStarted(true)
          setQuestionPhase(false)
          setResultPhase(true)
        } else if ('status' in data && data['status'] == 'waiting') {
          setGame(data['game'])
          setWaitingRoomOpen(true)
        }
      }
    })
    setGameChannel(game_channel)
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
      {questionPhase ? <Question question={question} gameChannel={gameChannel} setCurrentAnswer={setCurrentAnswer} /> : null }
      {resultPhase ? <Result question={question} /> : null }
    </div>
    )
}

export default App
