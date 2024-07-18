import { useEffect, useState } from "react"

import Views, { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Logo from "../components/Logo"
import Typer from "../components/Typer"

const nameRegex = /^[a-zA-Z0-9]{3,16}$/

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

    if (!nameRegex.test(name)) {
      alert("Name must be between 3 and 16 characters and contain only letters and numbers")
      return
    }

    const message: Message = {
      event: MessageEvent.Join,
      body: name.trim()
    }

    socket.send(JSON.stringify(message))
  }

  return (
    <>
      <Logo />
      <div className="flex-wrapper">
        <h1><Typer value="Welcome" ms={170} /></h1>
        <div className="start-input-wrapper">
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Your name..."
          />
          <button onClick={join}>Join</button>
          <p>Enter a name above to start chatting</p>
        </div>
      </div>
    </>
  )
}

export default StartView;
