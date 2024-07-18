import { useEffect, useState } from "react"
import { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Chat from "../models/chat"

const ChatView: React.FC<ViewProps> = ({ socket }) => {
  const [chats, setChats] = useState<Chat[]>([])
  const [chat, setChat] = useState("")

  useEffect(() => {
    const eventHandler = (event: globalThis.MessageEvent) => {
      const data: Message<Chat> = JSON.parse(event.data)

      if (data.event === MessageEvent.Chat) {
        setChats((prevChats) => [...prevChats, data.body])
      }
    }

    socket.addEventListener("message", eventHandler)
    return () => socket.removeEventListener("message", eventHandler)
  }, [socket, setChats])

  const sendChat = () => {
    if (chat.trim() === "") return

    const message: Message = {
      event: MessageEvent.Chat,
      body: chat
    }

    socket.send(JSON.stringify(message))
    setChat("")
  }

  return (
    <div>
      <h1>Chat</h1>
      <div>
        <input
          value={chat}
          onChange={(e) => setChat(e.target.value)}
          placeholder="Type your message here"
        />
        <button onClick={sendChat}>Send</button>
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
