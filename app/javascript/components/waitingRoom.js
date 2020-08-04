import React from "react"

const WaitingRoom = ({game}) => {
  return (
    <div>
      Current Players: {game.players.length}/{game.total_players_num}
      <br/>
      <hr/>
      <br/>
      <ol>
      {game.players.map((player, i) => (
        <li key={i}>{player.nickname}</li>
      ))}
      </ol>
      <hr/>
      <button id="leave" className="btn btn-danger" onClick={() => window.location.reload(false)}>
        Leave
      </button>
    </div>
  )
}

export default WaitingRoom
