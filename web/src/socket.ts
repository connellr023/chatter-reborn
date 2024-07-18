export let socket: WebSocket | null = null

window.onload = () => socket = new WebSocket("ws://localhost:3000/api/connect")
