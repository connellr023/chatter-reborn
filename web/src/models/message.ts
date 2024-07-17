export enum MessageEvent {
  Join = "join",
  Enqueued = "enqueued",
  Joined = "joined",
  Chat = "chat",
  Error = "error"
}

type Message = {
  event: MessageEvent,
  body: string
}

export default Message;
