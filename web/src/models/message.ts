enum MessageType {
  Join = "join",
  Chat = "chat",
  Error = "error"
}

type Message = {
  type: MessageType,
  body?: string
}

export default Message;
