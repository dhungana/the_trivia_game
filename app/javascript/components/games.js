import React from "react"

const Games = ({games, joinGame}) => {

  return (
    <table>
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
              <td><button className="btn btn-primary" onClick={() => joinGame(game.id)}>Join</button></td>
            </tr>
          ))}
      </tbody>
    </table>
  )
}

export default Games
