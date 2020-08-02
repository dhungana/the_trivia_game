import React, { useState } from "react"

const Question = ({question, setCurrentAnswer, gameChannel}) => {
  const handleClick = (event) => {
    event.preventDefault()
    gameChannel.send({action: 'send_answer',})
  }

  return (
    <div>
      <h2>{question.trivium.text}</h2>
      <br/>
      {question.trivium.choice1 ? question.trivium.choice1:''}
      <br/>
      {question.trivium.choice2 ? question.trivium.choice2:''}
      <br/>
      {question.trivium.choice3 ? question.trivium.choice3:''}
      <br/>
      {question.trivium.choice4 ? question.trivium.choice4:''}
    </div>
  )
}

export default Question
