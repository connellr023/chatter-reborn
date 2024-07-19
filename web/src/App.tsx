import { useState, useEffect, useRef } from "react"
import { useSocket } from "./hooks/useSocket"

import Views from "./models/views"
import StartView from "./views/StartView"
import MessageView from "./views/MessageView"
import ChatView from "./views/ChatView"
import Credit from "./components/Credit"
import { MessageEvent } from "./models/message"

const App = () => {
  const {
    addListener,
    removeListener,
    start,
    stop,
    onOpen,
    onClose,
    onError,
    send
  } = useSocket()

  const [view, setView] = useState<Views>(Views.Start)
  const [isSocketConnected, setIsSocketConnected] = useState(false)

  const socketRef = useRef<WebSocket | null>(null)
  const participantsRef = useRef<string[]>([])

  useEffect(() => {
    start()

    onOpen(() => {
      setView(Views.Start)
      setIsSocketConnected(true)

      console.log("Connected to server")

      onClose(() => {
        setIsSocketConnected(false)
        console.log("Connection closed")
      })

      onError(() => {
        setIsSocketConnected(false)
        console.log("Error connecting to server")
      })

      addListener(MessageEvent.Enqueued, () => {
        setView(Views.Queue)
      })

      addListener<string[]>(MessageEvent.Joined, (participants) => {
        participantsRef.current = participants
        setView(Views.Chat)
      })

      addListener<string>(MessageEvent.Error, (error) => {
        console.error(error)
      })
    })

    return () => {
      socketRef.current = null

      stop()
      setIsSocketConnected(false)
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  const renderViews = () => {
    if (!isSocketConnected) {
      return <MessageView message="Connecting to endpoint..." />
    }

    switch (view) {
      case Views.Start:
        return <StartView send={send} />
      case Views.Queue:
        return <MessageView message="Waiting for a match..." />
      case Views.Chat:
        return <ChatView
          addSocketListener={addListener}
          removeSocketListener={removeListener}
          setView={setView}
          participants={participantsRef.current}
          send={send}
        />
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
