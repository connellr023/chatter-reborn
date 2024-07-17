import { useContext, useEffect, useState } from "react";
import { ViewContext, Views } from "../contexts/viewContext";
import Message, { MessageEvent } from "../models/message";

type StartViewProps = {
  socket: WebSocket
}

const StartView: React.FC<StartViewProps> = ({ socket }) => {
  const [name, setName] = useState("")
  const { setView } = useContext(ViewContext)

  useEffect(() => {
    socket.addEventListener("message", (event) => {
      const data: Message = JSON.parse(event.data)

      if (data.event === MessageEvent.Enqueued) {
        setView(Views.Chat)
      }
    })

    return () => socket.removeEventListener("message", () => {})
  })

  const join = () => {
    if (!name) {
      alert("Please enter a name")
      return
    }

    const message: Message = {
      event: MessageEvent.Join,
      body: name
    }

    socket.send(JSON.stringify(message))
  }

  return (
    <>
      <h1>Chatter</h1>
      <div>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Enter a name"
        />
        <button onClick={join}>Join</button>
      </div>
    </>
  )
}

export default StartView;
