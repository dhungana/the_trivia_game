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

const ErrorMessage = ({errorMessage}) => (
  <div className="alert alert-danger" role="alert">
    {errorMessage}
  </div>
)

const TheGameDescription = () => (
  <div>
    <p>
      The game consists of multiple rounds. In each round players are presented a question, a
      choice of answers, and have to select one answer within the allotted time (30 seconds or
      so). Players that chose a correct answer advance to the next round. Those who chose
      the wrong answers are eliminated. The game continues until there’s only one winner left.
    </p>
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
  const [timer, setTimer] = useState(0)
  const [errorMessage, setErrorMessage] = useState('')

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
          } else {
            setTimer(10)
          }
        } else if ('error' in data) {
          setErrorMessage(data['error'])
        }
      }
    })
  }, [])

  useEffect(() => {
    const timer_ = timer > 0 && setInterval(() => setTimer(timer - 1), 1000)
    return () => clearInterval(timer_)
  }, [timer])

  useEffect(() => {
    const errorMessage_ = errorMessage !== '' && setInterval(() => setErrorMessage(''), 3000)
    return () => clearInterval(errorMessage_)
  }, [errorMessage])

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
          setTimer(30)
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
      {errorMessage === '' ? null: <ErrorMessage errorMessage={errorMessage} />}
      {!waitingRoomOpen && !gameStarted ? <TheGameDescription/> : null}
      {!waitingRoomOpen && !gameStarted ? <CreateGame playerChannel={playerChannel}/> : null}
      {!waitingRoomOpen && !gameStarted && games.length > 0 ?
        <Games games={games} joinGame={joinGame}/> : null}
      {waitingRoomOpen ? <WaitingRoom game={game} /> : null}
      {questionPhase ? <Question question={question} currentAnswer={currentAnswer} gameChannel={gameChannel} setCurrentAnswer={setCurrentAnswer} timer={timer}/> : null }
      {resultPhase ? <Result question={question} result={result} currentAnswer={currentAnswer} timer={timer}/> : null }
    </div>
    )
}

export default App
