import { useEffect } from "react"
import Credit from "./components/Credit"

const App = () => {
  useEffect(() => {
    const socket = new WebSocket("ws://localhost:3000/api/connect")

    socket.addEventListener("open", () => {
      console.log("Connected to server")
      socket.send("Hello from client")
    })

    return () => socket.close()
  }, [])

  return (
    <main>
      <h1>Chatter</h1>
      <div>
        <input placeholder="Enter a name" />
        <button>Join</button>
      </div>
      <Credit />
    </main>
  )
}

export default App
