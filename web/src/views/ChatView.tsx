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

const ChatView: React.FC<ChatViewProps> = ({ participants, setView, addSocketListener, removeSocketListener, send }) => {
  const [chats, setChats] = useState<Chat[]>([])
  const [chat, setChat] = useState("")
  const [isError, setIsError] = useState(false)
  const [isDisabled, setIsDisabled] = useState(true)

  useEffect(() => {
    addSocketListener("chat", (chat) => setChats((prevChats) => [...prevChats, chat]))
    return () => removeSocketListener("chat")
  }, [addSocketListener, removeSocketListener])

  const sendChat = () => {
    const message: Message = {
      event: MessageEvent.Chat,
      body: chat.trim()
    }

    send(JSON.stringify(message))

    setIsDisabled(true)
    setIsError(false)
    setChat("")
  }

  const requestDisconnect = () => {
    const message: Message = {
      event: MessageEvent.Disconnect,
      body: ""
    }

    send(JSON.stringify(message))
    setView(Views.Start)
  }

  const requestSkip = () => {
    const message: Message = {
      event: MessageEvent.Skip,
      body: ""
    }

    send(JSON.stringify(message))
  }

  const handleChatChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const isValid = chatRegex.test(e.target.value) && e.target.value.length > 0

    setIsError(!isValid)
    setIsDisabled(!isValid)
    setChat(e.target.value)
  }

  return (
    <>
      <Logo />
      <div className="flex-wrapper chat-view-wrapper">
        <h1>You are chatting with {participants.join(", ")}!</h1>
        <p>Say <b>hi</b> by typing in the message box below...</p>
        <div className="input-wrapper">
          <input
            className={isError ? "error" : ""}
            value={chat}
            onChange={handleChatChange}
            placeholder="Type your message here"
          />
          <div className="button-wrapper">
            <button onClick={sendChat} disabled={isDisabled}>Send</button>
            <button onClick={requestSkip}>Skip</button>
            <button onClick={requestDisconnect}>Disconnect</button>
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
