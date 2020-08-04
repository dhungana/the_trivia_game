import React, { useState } from "react"

const Result = ({question, result, currentAnswer, timer}) => {

  return (
    <div>
      {result === 'won' ? (<h1>Congratulations! You won!</h1>) : (
        result === 'progressed' ? (<h1>You progressed to the next round!</h1>) : (
          result === 'eliminated' ? (<h1>Sorry! You were eliminated!</h1> ) : null
          )
        )
      }
      { result === 'progressed' ? (
        <div className="center-circle">
          <br/>
          <div className="circle">
            {timer}
          </div>
          <br/>
        </div>
      ): null}
      <hr/>
      <h2>{question.trivium.text}</h2>
      <br/><br/>

      {question.trivium.choice1 ?
      (<button id="result1" className={question.trivium.correct_answer === question.trivium.choice1 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice1 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice1}>
          {question.trivium.choice1} : {question.choice1_num}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice2 ?
      (<button id="result2" className={question.trivium.correct_answer === question.trivium.choice2 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice2 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice2}>
          {question.trivium.choice2} : {question.choice2_num}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice3 ?
      (<button id="result3" className={question.trivium.correct_answer === question.trivium.choice3 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice3 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice3}>
          {question.trivium.choice3} : {question.choice3_num}
      </button>)
      :''}
      <br/><br/>
      {question.trivium.choice4 ?
      (<button id="result4" className={question.trivium.correct_answer === question.trivium.choice4 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice4 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice4}>
          {question.trivium.choice4} : {question.choice4_num}
      </button>)
      :''}
      {result === 'won' || result === 'eliminated' ? (
        <div>
          <hr/>
          <button id="another_game" className="btn btn-primary" onClick={() => window.location.reload(false)}>
            Another Game
          </button>
        </div>
      ): null}
    </div>
  )
}

export default Result
