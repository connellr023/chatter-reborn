import { useState, useEffect, useRef } from "react"
import { Views, ViewContext } from "./contexts/viewContext"

import StartView from "./views/StartView"
import Credit from "./components/Credit"

const App = () => {
  const [viewContext, setViewContext] = useState<Views>(Views.Start)
  const socket = useRef<WebSocket | null>(null)

  useEffect(() => {
    socket.current = new WebSocket("ws://localhost:3000/api/connect")

    socket.current.addEventListener("open", () => {
      setViewContext(Views.Start)
      console.log("Connected to server")
    })

    socket.current.addEventListener("error", () => {
      setViewContext(Views.Error)
      console.log("Error connecting to server")
    })

    return () => socket.current?.close()
  }, [])

  const renderViews = () => {
    if (!socket.current) {
      return <div>Loading...</div>
    }

    switch (viewContext) {
      case Views.Start:
        return <StartView socket={socket.current} />
      case Views.Chat:
        return <div>Chat</div>
      case Views.Error:
        return <div>Error</div>
      case Views.Queue:
        return <div>Queue</div>
    }
  }

  return (
    <ViewContext.Provider value={{ value: viewContext, setView: setViewContext }}>
      {renderViews()}
      <Credit />
    </ViewContext.Provider>
  )
}

export default App
