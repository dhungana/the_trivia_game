import React, { useState } from "react"
import { Button } from 'react-bootstrap'

const Question = ({question, currentAnswer, setCurrentAnswer, gameChannel, timer}) => {

  const handleClick = (event) => {
    setCurrentAnswer(event.target.value)
    gameChannel.send({action: 'send_answer', answer: event.target.value})
  }

  return (
    <div>
      <h2 id="question">{question.trivium.text}</h2>
      <br/>
      <div className="center-circle">
        <div className="circle">
          {timer}
        </div>
      </div>
      <br/>
      {question.trivium.choice1 ?
      (<button id="choice1" className={currentAnswer === question.trivium.choice1 ? "btn btn-primary" : "btn  btn-warning"}
        value={question.trivium.choice1} onClick={currentAnswer === '' && timer > 0 ? handleClick : null}>
          {question.trivium.choice1}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice2 ?
      (<button id="choice2" className={currentAnswer === question.trivium.choice2 ? "btn btn-primary" : "btn  btn-warning"}
        value={question.trivium.choice2} onClick={currentAnswer === '' && timer > 0 ? handleClick : null}>
          {question.trivium.choice2}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice3 ?
      (<button id="choice3" className={currentAnswer === question.trivium.choice3 ? "btn btn-primary" : "btn  btn-warning"}
        value={question.trivium.choice3} onClick={currentAnswer === '' && timer > 0 ? handleClick : null}>
          {question.trivium.choice3}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice4 ?
      (<button id="choice4"  className={currentAnswer === question.trivium.choice4 ? "btn btn-primary" : "btn  btn-warning"}
        value={question.trivium.choice4} onClick={currentAnswer === '' && timer > 0 ? handleClick : null}>
          {question.trivium.choice4}
      </button>)
      :''}
    </div>
  )
}

export default Question
