enum MessageEvent {
  Join = "join",
  Chat = "chat",
  Error = "error"
}

type Message = {
  event: MessageEvent,
  body: string
}

export default Message;
