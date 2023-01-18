import React, { useRef, useState, useEffect } from "react"
import { useNavigate, useLocation } from "react-router-dom"
import RoundedButton from "./RoundedButton"

const randomInteger = (min, max) => {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

const DEFAULT_QUESTION = 'What is The Minimalist Entrepreneur about?'
const LUCKY_QUESTIONS = [
  "What is a minimalist entrepreneur?",
  "What is your definition of community?",
  "How do I decide what kind of business I should start?"
]

export default () => {
  const [question, setQuestion] = useState(DEFAULT_QUESTION)
  const [response, setResponse] = useState(null)
  const [answer, setAnswer] = useState('')
  const [showAskAnotherButton, setShowAskAnotherButton] = useState(false)
  const [asking, setAsking] = useState(false)
  const answerRef = useRef('')
  const responseRef = useRef(null)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => { answerRef.current = answer }, [answer])
  useEffect(() => { responseRef.current = response }, [response])
  useEffect(() => {
    if (location.pathname.match(/\/question\/\d+/)) {
      const questionId = location.pathname.split('/')[2]
      if (questionId && Number(questionId) !== responseRef.current?.id) {
        fetch(`/api/v1/questions/${questionId}`, { method: 'GET' })
          .then((response) => response.json())
          .then((response) => {
            setResponse(response)
            setQuestion(response.question)
            setAnswer(response.answer)
            setShowAskAnotherButton(true)
          })
      }
    } else if (location.pathname === '/') {
      resetState()
    }
  }, [location.pathname])

  const resetState = () => {
    setResponse(null)
    setAnswer('')
    setQuestion(DEFAULT_QUESTION)
    setShowAskAnotherButton(false)
  }

  const onAsk = (askedQuestion) => {
    setAsking(true)
    fetch('/api/v1/questions/ask', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ question: askedQuestion })
    }).then((response) => response.json())
      .then((response) => {
        setAsking(false)
        setResponse(response)
        setTimeout(() => {
          showAnswer(response.answer, 0)
        }, 1200)
        navigate(`/question/${response.id}`)
      })
  }

  const onFeelingLucky = () => {
    const randomQuestion = LUCKY_QUESTIONS[~~(Math.random() * LUCKY_QUESTIONS.length)]
    setQuestion(randomQuestion)
    onAsk(randomQuestion)
  }

  const showAnswer = (message, index) => {
    if (index < message.length) {
      setAnswer(answerRef.current + message[index++])
      setTimeout(() => {
        showAnswer(message, index)
      }, randomInteger(30, 70))
    } else {
      setShowAskAnotherButton(true)
    }
  }

  return (
    <div className="max-w-lg mx-auto">
      <h1 className="font-bold text-xl text-center">Ask My Book</h1>
      <p className="text-gray-700 text-base">
        This is an experiment in using AI to make my book's content more accessible. Ask a question and I'll answer it
        in real-time:
      </p>
      <textarea className="w-full border rounded p-2" value={question} onChange={(e) => setQuestion(e.target.value)}/>
      {!response ? (
        <div className="text-center py-2">
          <RoundedButton className="bg-black text-white mr-10" disabled={asking} onClick={() => { onAsk(question) }}>{asking ? 'Asking...' : 'Ask question'}</RoundedButton>
          <RoundedButton className="bg-gray-200 text-gray-700" disabled={asking} onClick={onFeelingLucky}>I'm feeling lucky</RoundedButton>
        </div>
      ) : (
        <div className="py-2">
          {response && <b>Answer: </b>}
          {answer}
        </div>
      )}
      {showAskAnotherButton &&
        <div className="py-2">
          <RoundedButton className="bg-black text-white" onClick={() => {
            resetState()
            navigate('/')
          }}>Ask another question</RoundedButton>
        </div>
      }
    </div>
  )
}
