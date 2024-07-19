enum Views {
  Start,
  Queue,
  Chat,
  Error
}

export type ViewProps<M = undefined, S = undefined> = {
  socket: WebSocket,
  setView: (view: Views, meta?: S) => void,
  meta?: M
}

export default Views;
