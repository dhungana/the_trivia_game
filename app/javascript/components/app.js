import React, { useState, useEffect } from "react"
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
  const [result, setResult] = useState('')
  const [gameChannel, setGameChannel] = useState({})
  const [playerChannel, setPlayerChannel] = useState({})

  useEffect(() => {
    const active_games_channel = consumer.subscriptions.create({channel: "ActiveGamesChannel"}, {
      received: function(data) {
        if ('games' in data) {
          setGames(data.games)
        }
      }
    })

    const player_channel = consumer.subscriptions.create({channel: "PlayerChannel"}, {
      connected: function() {
        player_channel.send({action: 'get_games'})
      },
      initialized: function() {
        setPlayerChannel(this)
      },
      received: function(data) {
        if ('games' in data) {
          setGames(data.games)
        } else if ('game_id' in data) {
          joinGame(data['game_id'], data['nickname'])
        } else if ('status' in data && data['status'] == 'result') {
          setQuestion(data['question'])
          setWaitingRoomOpen(false)
          setGameStarted(true)
          setQuestionPhase(false)
          setResultPhase(true)
          setResult(data['result'])
          if (data['result'] === 'won' || data['result'] === 'eliminated') {
            consumer.disconnect()
          }
        }
      }
    })
  }, [])

  const joinGame = (game_id, nickname) => {
    const game_channel = consumer.subscriptions.create({channel: "GameChannel", game_id: game_id, nickname: nickname}, {
      initialized: function() {
        setGameChannel(this)
      },
      received: function(data) {
        if ('status' in data && data['status'] == 'question') {
          setQuestion(data['question'])
          setWaitingRoomOpen(false)
          setGameStarted(true)
          setQuestionPhase(true)
          setResultPhase(false)
          setCurrentAnswer('')
        } else if ('status' in data && data['status'] == 'waiting' && !gameStarted) {
          setGame(data['game'])
          setWaitingRoomOpen(true)
        }
      }
    })
  }

  return (
    <div>
      <Heading />
      {!waitingRoomOpen && !gameStarted ? <CreateGame playerChannel={playerChannel}/> : null}
      {!waitingRoomOpen && !gameStarted && games.length > 0 ?
        <Games games={games} joinGame={joinGame}/> : null}
      {waitingRoomOpen ? <WaitingRoom game={game} /> : null}
      {questionPhase ? <Question question={question} currentAnswer={currentAnswer} gameChannel={gameChannel} setCurrentAnswer={setCurrentAnswer} /> : null }
      {resultPhase ? <Result question={question} result={result} currentAnswer={currentAnswer}/> : null }
    </div>
    )
}

export default App
