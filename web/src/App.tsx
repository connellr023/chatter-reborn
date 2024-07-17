import { useState, useEffect, useRef } from "react"
import { AppContext, AppContextValues, Views } from "./contexts/appContext"
import Credit from "./components/Credit"

const App = () => {
  const [appContext, setAppContext] = useState<AppContextValues>({ currentView: Views.Start })
  const socket = useRef<WebSocket | null>(null)

  useEffect(() => {
    socket.current = new WebSocket("ws://localhost:3000/api/connect")

    socket.current.addEventListener("open", () => {
      console.log("Connected to server")
    })

    socket.current.addEventListener("error", () => {
      console.log("Error connecting to server")
    })

    return () => socket.current?.close()
  }, [])

  return (
    <AppContext.Provider value={{ value: appContext, setValue: setAppContext }}>
      <Credit />
    </AppContext.Provider>
  )
}

export default App
