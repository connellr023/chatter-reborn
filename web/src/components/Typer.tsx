import { useEffect, useState } from "react"

type TyperProps = {
  value: string
  ms: number
}

const Typer: React.FC<TyperProps> = ({ value, ms }) => {
  const [text, setText] = useState("")
  const [index, setIndex] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setText(value.slice(0, index))
      setIndex(index + 1)
    }, ms)

    return () => clearInterval(interval)
  }, [value, index, ms])

  return <span>{text}<span style={{ opacity: (index % 2 === 0 ? 0 : 1) }}>_</span></span>
}

export default Typer
