import { useEffect } from "react"
import Views, { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Logo from "../components/Logo"

const QueueView: React.FC<ViewProps<undefined, string[]>> = ({ socket, setView }) => {
  useEffect(() => {
    const eventHandler = (event: globalThis.MessageEvent) => {
      const data: Message<string[]> = JSON.parse(event.data)

      if (data.event === MessageEvent.Joined) {
        setView(Views.Chat, data.body)
      }
    }

    socket.addEventListener("message", eventHandler)
    return () => socket.removeEventListener("message", eventHandler)
  }, [socket, setView])

  return (
    <>
      <Logo />
      <div className="flex-wrapper">
        <h1>You are in queue...</h1>
      </div>
    </>
  )
}

export default QueueView
