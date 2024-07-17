export enum MessageEvent {
  Join = "join",
  Enqueued = "enqueued",
  Joined = "joined",
  Chat = "chat",
  Error = "error"
}

type Message<B = string> = {
  event: MessageEvent,
  body: B
}

export default Message;
