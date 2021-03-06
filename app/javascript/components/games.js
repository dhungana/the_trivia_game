import React, { useState } from "react"
import { Button, Modal } from 'react-bootstrap'

const Games = ({games, joinGame}) => {
  const [show, setShow] = useState(false)
  const [nickname, setNickname] = useState('')
  const [gameToJoin, setGameToJoin] = useState(null)

  const handleClose = () => setShow(false)
  const handleShow = (game) => {
    setGameToJoin(game)
    setShow(true)
  }

  return (
    <div>
      <table className="center">
        <thead>
          <tr>
            <th>Name</th>
            <th>Started By</th>
            <th>Players</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {games.map(game => (
              <tr key={game.id}>
                <td>{game.name}</td>
                <td>{game.started_by.nickname}</td>
                <td>{game.players ? game.players.length : 0}/{game.total_players_num}</td>
                <td>
                  <Button id={"joinGame"+ game.name + Math.random.toString()}variant="primary" onClick={() => handleShow(game)}>
                    Join
                  </Button>
                </td>
              </tr>
            ))}
        </tbody>
      </table>
      <Modal show={show} onHide={handleClose}>
        <form onSubmit={(event) => {event.preventDefault();
                                      joinGame(gameToJoin.id, nickname);
                                      handleClose()}} >
          <Modal.Header closeButton>
            <Modal.Title>Join Game</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            Your Nickname: <input id="joinNickname" value={nickname} onChange={(e) => setNickname(e.target.value)} required/><br/>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={handleClose}>
              Close
            </Button>
            <Button id="joinSubmit" variant="primary" type="submit">
              Join
            </Button>
          </Modal.Footer>
        </form>
      </Modal>
    </div>
  )
}

export default Games
