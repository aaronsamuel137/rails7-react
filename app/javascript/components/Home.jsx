import React, { useState } from "react";
import RoundedButton from "./RoundedButton";

export default () => {
  const [question, setQuestion] = useState("What is The Minimalist Entrepreneur about?")
  const onAsk = () => {
    fetch('/api/v1/questions/ask', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ question })
    }).then((response) => response.json())
      .then((response) => {
        console.log(response)
    })
  }

  return (
    <div className="max-w-lg mx-auto">
      <h1 className="font-bold text-xl text-center">Ask My Book</h1>
      <p className="text-gray-700 text-base">
        This is an experiment in using AI to make my book's content more accessible. Ask a question and I'll answer it
        in
        real-time:
      </p>
      <textarea className="w-full border rounded p-2" value={question} onChange={(e) => setQuestion(e.target.value)}/>
      <div className="text-center py-2">
        <RoundedButton className="bg-black text-white mr-10" onClick={onAsk}>Ask question</RoundedButton>
        <RoundedButton className="bg-gray-200 text-gray-700">I'm feeling lucky</RoundedButton>
      </div>
    </div>
  )
}
