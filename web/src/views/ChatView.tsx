import { useEffect, useState } from "react"
import Views, { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Chat from "../models/chat"

const chatRegex = /^[a-zA-Z0-9 .,!?'"@#%^&*()_+-=;:~`]*$/

const ChatView: React.FC<ViewProps> = ({ socket, setView }) => {
  const [chats, setChats] = useState<Chat[]>([])
  const [chat, setChat] = useState("")

  useEffect(() => {
    const eventHandler = (event: globalThis.MessageEvent) => {
      const data: Message<Chat> = JSON.parse(event.data)

      switch (data.event) {
        case MessageEvent.Chat:
          setChats((prevChats) => [...prevChats, data.body])
          break
        case MessageEvent.Enqueued:
          setView(Views.Queue)
          break
        default:
          break
      }
    }

    socket.addEventListener("message", eventHandler)
    return () => socket.removeEventListener("message", eventHandler)
  }, [socket, setChats, setView])

  const sendChat = () => {
    if (!chatRegex.test(chat)) {
      alert("Invalid chat message")
      return
    }

    const message: Message = {
      event: MessageEvent.Chat,
      body: chat.trim()
    }

    socket.send(JSON.stringify(message))
    setChat("")
  }

  return (
    <div className="flex-wrapper">
      <h1>Chat</h1>
      <div>
        <input
          value={chat}
          onChange={(e) => setChat(e.target.value)}
          placeholder="Type your message here"
        />
        <button onClick={sendChat}>Send</button>
        <button>Skip</button>
        <button>Disconnect</button>
        <ul>
          {chats.map((chat, index) => (
            <li key={index}>
              <p>{chat.source}</p>
              <p>{chat.content}</p>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}

export default ChatView
