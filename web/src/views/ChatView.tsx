import { useEffect, useState } from "react"

import Views from "../models/views"
import Message, { MessageEvent } from "../models/message"
import Chat from "../models/chat"
import Logo from "../components/Logo"

const chatRegex = /^[a-zA-Z0-9 .,!?'"@#%^&*()_+-=;:~`]*$/

type ChatViewProps = {
  participants: string[],
  setView: (view: Views) => void,
  addSocketListener: (event: string, callback: (body: Chat) => void) => void,
  removeSocketListener: (event: string) => void,
  send: (data: string) => void
}

const ChatView: React.FC<ChatViewProps> = ({ participants, addSocketListener, removeSocketListener, send }) => {
  const [chats, setChats] = useState<Chat[]>([])
  const [chat, setChat] = useState("")

  useEffect(() => {
    addSocketListener("chat", (chat) => setChats((prevChats) => [...prevChats, chat]))
    return () => removeSocketListener("chat")
  }, [addSocketListener, removeSocketListener])

  const sendChat = () => {
    if (!chatRegex.test(chat) || chat.length === 0) {
      alert("Invalid chat message")
      return
    }

    const message: Message = {
      event: MessageEvent.Chat,
      body: chat.trim()
    }

    send(JSON.stringify(message))
    setChat("")
  }

  return (
    <>
      <Logo />
      <div className="flex-wrapper chat-view-wrapper">
        <h1>You are chatting with {participants.join(", ")}!</h1>
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
              <li key={index} className={participants.includes(chat.source) ? "" : "owned"}>
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
