import { createContext } from "react"

export enum Views {
  Start,
  Queue,
  Chat,
  Error
}

export type ViewContextType = {
  value: Views,
  setView: (view: Views) => void
}

export const ViewContext = createContext<ViewContextType>({
  value: Views.Start,
  setView: () => {}
})
