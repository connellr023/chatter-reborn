import { useRef } from "react"

import Message from "../models/message"

export const useSocket = () => {
  const socket = useRef<WebSocket | null>(null)
  const listners = useRef(new Map<string, (body: unknown) => void>())

  const onOpen = (callback: () => void) => {
    if (!socket.current) return
    socket.current.addEventListener("open", callback)
  }

  const onClose = (callback: () => void) => {
    if (!socket.current) return
    socket.current.addEventListener("close", callback)
  }

  const onError = (callback: () => void) => {
    if (!socket.current) return
    socket.current.addEventListener("error", callback)
  }

  const addListener = <T>(event: string, callback: (body: T) => void) => {
    listners.current.set(event, callback as (body: unknown) => void)
  }

  const removeListener = (event: string) => {
    listners.current.delete(event)
  }

  const eventHandler = (event: globalThis.MessageEvent) => {
    const data: Message = JSON.parse(event.data)
    const callback = listners.current.get(data.event)

    if (callback) {
      callback(data.body)
    }
  }

  const start = () => {
    socket.current = new WebSocket("ws://localhost:3000/api/connect")
    socket.current.addEventListener("message", eventHandler)
  }

  const stop = () => {
    if (!socket.current) return
    socket.current.removeEventListener("message", eventHandler)
    socket.current.close()
  }

  const send = (data: string) => {
    if (!socket.current) return
    socket.current.send(data)
  }

  return {
    addListener,
    removeListener,
    start,
    stop,
    onOpen,
    onClose,
    onError,
    send
  }
}
