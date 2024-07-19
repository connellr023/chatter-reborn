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
  const [isError, setIsError] = useState(false)
  const [isDisabled, setIsDisabled] = useState(true)

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const isValid = nameRegex.test(e.target.value) && e.target.value.length > 0

    setIsError(!isValid)
    setIsDisabled(!isValid)
    setName(e.target.value)
  }

  const join = () => {
    if (!name) {
      alert("Please enter a name")
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
            className={isError ? "error" : ""}
            value={name}
            onChange={handleNameChange}
            placeholder="Your name..."
          />
          <button onClick={join} disabled={isDisabled}>Join</button>
          <p>Enter a name above to start chatting</p>
        </div>
      </div>
    </>
  )
}

export default StartView;
