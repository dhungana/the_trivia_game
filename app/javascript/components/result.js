import React, { useState } from "react"

const Question = ({question}) => {

  return (
    <div>
      <h2>{question.trivium.correct_answer}</h2>
      <br/>
    </div>
  )
}

export default Question
