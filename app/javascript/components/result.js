import React, { useState } from "react"

const Result = ({question, result, currentAnswer}) => {

  return (
    <div>
      <h1>{result}</h1>
      <h2>{question.trivium.text}</h2>
      <br/>
      {question.trivium.choice1 ?
      (<button className={question.trivium.correct_answer === question.trivium.choice1 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice1 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice1}>
          {question.trivium.choice1} : {question.choice1_num}
      </button>)
      :''}
      <br/>
      {question.trivium.choice2 ?
      (<button className={question.trivium.correct_answer === question.trivium.choice2 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice2 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice2}>
          {question.trivium.choice2} : {question.choice2_num}
      </button>)
      :''}
      <br/>
      {question.trivium.choice3 ?
      (<button className={question.trivium.correct_answer === question.trivium.choice3 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice3 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice3}>
          {question.trivium.choice3} : {question.choice3_num}
      </button>)
      :''}
      <br/>
      {question.trivium.choice4 ?
      (<button className={question.trivium.correct_answer === question.trivium.choice4 ? "btn btn-success" :
        (currentAnswer === question.trivium.choice4 ? "btn btn-danger" : "btn btn-warning")}
        value={question.trivium.choice4}>
          {question.trivium.choice4} : {question.choice4_num}
      </button>)
      :''}
    </div>
  )
}

export default Result
