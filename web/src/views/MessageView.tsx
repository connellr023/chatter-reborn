import Logo from "../components/Logo"

type MessageViewProps = {
  message: string
}

const MessageView: React.FC<MessageViewProps> = ({ message }) => {
  return (
    <>
      <Logo />
      <div className="flex-wrapper">
        <h1>{message}</h1>
      </div>
    </>
  )
}

export default MessageView
