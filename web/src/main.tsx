import React from "react"
import ReactDOM from "react-dom/client"
import App from "./App.tsx"

import "./styles/main.scss"

const root = document.getElementById("root")!

ReactDOM.createRoot(root).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
