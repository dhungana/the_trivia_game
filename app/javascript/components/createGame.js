import React, { useState } from "react"
import { Button, Modal } from 'react-bootstrap'

const CreateGame = ({playerChannel}) => {
  const [show, setShow] = useState(false)
  const [gameName, setGameName] = useState('')
  const [totalPlayersNum, setTotalPlayersNum] = useState(4)
  const [nickname, setNickname] = useState('')

  const handleClose = () => setShow(false)
  const handleShow = () => setShow(true)
  const handleCreateGame = (event) => {
    event.preventDefault()
    playerChannel.send({action: 'create_game',
                        game_name: gameName,
                        total_players_num: totalPlayersNum,
                        nickname: nickname})
    handleClose()
  }

  return (
    <div>
      <div>
        <Button variant="primary" onClick={handleShow}>
          Create Game
        </Button>
        <hr/>
      </div>
      <Modal show={show} onHide={handleClose}>
        <form onSubmit={handleCreateGame} >
          <Modal.Header closeButton>
            <Modal.Title>Create Game</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            Game Name: <input value={gameName} onChange={(e) => setGameName(e.target.value)}/><br/>
            Minimum Players: <input value={totalPlayersNum} onChange={(e) => setTotalPlayersNum(e.target.value)}/><br/>
            Your Nickname: <input value={nickname} onChange={(e) => setNickname(e.target.value)}/><br/>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={handleClose}>
              Close
            </Button>
            <Button variant="primary" type="submit">
              Create
            </Button>
          </Modal.Footer>
        </form>
      </Modal>
    </div>
  )
}

export default CreateGame
