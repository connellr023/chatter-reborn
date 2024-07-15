import { useEffect, useState, useRef } from "react"
import Credit from "./components/Credit"

const App = () => {
  const [name, setName] = useState("")
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

  const join = () => {
    if (!name) {
      alert("Please enter a name")
      return
    }

    socket.current?.send(JSON.stringify({ type: "join", name }))
  }

  return (
    <main>
      <h1>Chatter</h1>
      <div>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Enter a name"
        />
        <button onClick={join}>Join</button>
      </div>
      <Credit />
    </main>
  )
}

export default App
