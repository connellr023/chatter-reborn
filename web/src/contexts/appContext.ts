import { createContext } from "react"

export enum Views {
  Start,
  Queue,
  Chat
}

export type AppContextValues = {
  currentView: Views,
  socket?: WebSocket
}

export type AppContextType = {
  value: AppContextValues,
  setValue: (value: AppContextValues) => void
}

export const AppContext = createContext<AppContextType>({
  value: { currentView: Views.Start },
  setValue: () => {}
})
