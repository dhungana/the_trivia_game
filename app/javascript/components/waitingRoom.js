import React from "react"

const WaitingRoom = ({game}) => {
  return (
    <div>
      Current Players: {game.players.length}/{game.total_players_num}
      <br/>
      <br/>
      <ol>
      {game.players.map(player => (
        <li key={player.nickname}>{player.nickname}</li>
      ))}
      </ol>
    </div>
  )
}

export default WaitingRoom
