import { useEffect, useState } from "react"
import Views, { ViewProps } from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Chat from "../models/chat"
import Logo from "../components/Logo"

const chatRegex = /^[a-zA-Z0-9 .,!?'"@#%^&*()_+-=;:~`]*$/

const ChatView: React.FC<ViewProps<string[]>> = ({ socket, setView, meta }) => {
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
    if (!chatRegex.test(chat) || chat.length === 0) {
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
    <>
      <Logo />
      <div className="flex-wrapper chat-view-wrapper">
        <h1>You are chatting with {meta?.join(", ")}!</h1>
        <p>Say <b>hi</b> by typing in the message box below...</p>
        <div className="input-wrapper">
          <input
            value={chat}
            onChange={(e) => setChat(e.target.value)}
            placeholder="Type your message here"
          />
          <div className="button-wrapper">
            <button onClick={sendChat}>Send</button>
            <button>Skip</button>
            <button>Disconnect</button>
          </div>
          <ul>
            {chats.map((chat, index) => (
              <li key={index} className={meta?.includes(chat.source) ? "" : "owned"}>
                <div className="source">{chat.source}</div>
                <div className="content">{chat.content}</div>
              </li>
            )).reverse()}
          </ul>
        </div>
      </div>
    </>
  )
}

export default ChatView
