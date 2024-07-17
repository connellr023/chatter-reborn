import { useState, useEffect, useRef } from "react"

import Views from "./models/views"
import StartView from "./views/StartView"
import QueueView from "./views/QueueView"
import ChatView from "./views/ChatView"
import ErrorView from "./views/ErrorView"
import Credit from "./components/Credit"

const App = () => {
  const [view, setView] = useState<Views>(Views.Start)
  const socket = useRef<WebSocket | null>(null)

  useEffect(() => {
    socket.current = new WebSocket("ws://localhost:3000/api/connect")

    socket.current.addEventListener("open", () => {
      setView(Views.Start)
      console.log("Connected to server")
    })

    socket.current.addEventListener("close", () => {
      setView(Views.Error)
      console.log("Connection closed")
    })

    socket.current.addEventListener("error", () => {
      setView(Views.Error)
      console.log("Error connecting to server")
    })

    return () => socket.current?.close()
  }, [])

  const renderViews = () => {
    if (!socket.current) {
      return <div>Loading...</div>
    }

    switch (view) {
      case Views.Start:
        return <StartView socket={socket.current} setView={setView} />
      case Views.Chat:
        return <ChatView socket={socket.current} setView={setView} />
      case Views.Queue:
        return <QueueView socket={socket.current} setView={setView} />
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
