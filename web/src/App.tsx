import { useState, useEffect, useRef } from "react"

import Views from "./models/views"
import StartView from "./views/StartView"
import QueueView from "./views/QueueView"
import ChatView from "./views/ChatView"
import ErrorView from "./views/ErrorView"
import Credit from "./components/Credit"

const App = () => {
  const [view, setView] = useState<Views>(Views.Start)
  const [isSocketConnected, setIsSocketConnected] = useState(false)

  const socketRef = useRef<WebSocket | null>(null)
  const chatMetaRef = useRef<string[]>([])

  useEffect(() => {
    const ws = new WebSocket("ws://localhost:3000/api/connect")

    ws.addEventListener("open", () => {
      setView(Views.Start)
      setIsSocketConnected(true)

      console.log("Connected to server")
    })

    ws.addEventListener("close", () => {
      setView(Views.Error)
      setIsSocketConnected(false)

      console.log("Connection closed")
    })

    ws.addEventListener("error", () => {
      setView(Views.Error)
      setIsSocketConnected(false)
      console.log("Error connecting to server")
    })

    socketRef.current = ws

    return () => {
      socketRef.current?.close()
      socketRef.current = null
      setIsSocketConnected(false)
    }
  }, [])

  const renderViews = () => {
    if (!isSocketConnected) {
      return <div>Loading...</div>
    }

    switch (view) {
      case Views.Start:
        return <StartView socket={socketRef.current!} setView={setView} />
      case Views.Queue:
        return <QueueView socket={socketRef.current!} setView={(view, meta) => {
          setView(view)
          if (meta) {
            chatMetaRef.current = meta
          }
        }} />
      case Views.Chat:
        return <ChatView socket={socketRef.current!} setView={setView} meta={chatMetaRef.current} />
      case Views.Error:
        return <ErrorView />
    }
  }

  return (
    <main>
      {renderViews()}
      <Credit />
    </main>
  )
}

export default App
