import { useEffect } from "react"
import Views, { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"

const QueueView: React.FC<ViewProps> = ({ socket, setView }) => {
  useEffect(() => {
    const eventHandler = (event: globalThis.MessageEvent) => {
      const data: Message = JSON.parse(event.data)

      if (data.event === MessageEvent.Joined) {
        setView(Views.Chat)
      }
    }

    socket.addEventListener("message", eventHandler)
    return () => socket.removeEventListener("message", eventHandler)
  }, [socket, setView])

  return (
    <div>
      <h1>You are in queue...</h1>
    </div>
  )
}

export default QueueView
