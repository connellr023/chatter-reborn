export enum MessageEvent {
  Join = "join",
  Enqueued = "enqueued",
  Joined = "joined",
  Chat = "chat",
  Error = "error",
  Disconnect = "disconnect",
  Skip = "skip"
}

type Message<BodyType = string> = {
  event: MessageEvent,
  body: BodyType
}

export default Message;
