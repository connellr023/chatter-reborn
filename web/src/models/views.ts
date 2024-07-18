enum Views {
  Start,
  Queue,
  Chat,
  Error
}

export type ViewProps = {
  socket: WebSocket,
  setView: (view: Views) => void
}

export default Views;
