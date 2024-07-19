import { useState } from "react"

import Message, { MessageEvent } from "../models/message"
import Logo from "../components/Logo"
import Typer from "../components/Typer"

const nameRegex = /^[a-zA-Z0-9]{3,16}$/

type StartViewProps = {
  send: (data: string) => void
}

const StartView: React.FC<StartViewProps> = ({ send }) => {
  const [name, setName] = useState("")

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

    send(JSON.stringify(message))
  }

  return (
    <>
      <Logo />
      <div className="flex-wrapper">
        <h1><Typer value="Welcome" ms={170} /></h1>
        <div className="input-wrapper">
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
