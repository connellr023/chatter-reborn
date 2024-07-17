import { useEffect, useState } from "react";
import Views, { ViewProps } from "../models/views";
import Message, { MessageEvent } from "../models/message";

const StartView: React.FC<ViewProps> = ({ socket, setView }) => {
  const [name, setName] = useState("")

  useEffect(() => {
    const eventHandler = (event: globalThis.MessageEvent) => {
      const data: Message = JSON.parse(event.data)

      if (data.event === MessageEvent.Enqueued) {
        setView(Views.Queue)
      }
    }

    socket.addEventListener("message", eventHandler)
    return () => socket.removeEventListener("message", eventHandler)
  }, [socket, setView])

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
