import Credit from "./components/Credit"

const App = () => {
  return (
    <main>
      <h1>Chatter</h1>
      <div>
        <input placeholder="Enter a name" />
        <button>Join</button>
      </div>
      <Credit />
    </main>
  )
}

export default App
