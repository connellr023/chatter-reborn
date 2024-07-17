import { useEffect, useRef, useState } from "react";
import { AppContext } from "../contexts/appContext";

const StartView = () => {
  const [name, setName] = useState("")

  const join = () => {
    if (!name) {
      alert("Please enter a name")
      return
    }

    socket.current?.send(JSON.stringify({ event: "join", body: name }))
  }

  return (
    <AppContext.Consumer >
      {(context) => {
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
      }}
    </AppContext.Consumer>
  )
}

export default StartView;
