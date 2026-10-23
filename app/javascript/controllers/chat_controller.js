import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Sends and receives chat messages over the ChatChannel WebSocket.
export default class extends Controller {
  static targets = [ "messages", "message", "input", "button", "status", "error" ]
  static values = { currentUserId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create("ChatChannel", {
      connected: () => this.setConnected(true),
      disconnected: () => this.setConnected(false),
      received: (data) => this.received(data)
    })
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  send(event) {
    event.preventDefault()

    const body = this.inputTarget.value.trim()
    if (body === "") return

    this.subscription.perform("speak", { body })
    this.inputTarget.value = ""
    this.showError("")
  }

  received(data) {
    if (data.error) {
      this.showError(data.error)
    } else if (data.html) {
      this.messagesTarget.insertAdjacentHTML("beforeend", data.html)
    }
  }

  // Runs for messages rendered on page load and for each one appended later.
  messageTargetConnected(element) {
    if (Number(element.dataset.authorId) === this.currentUserIdValue) {
      element.classList.replace("items-start", "items-end")
      element.querySelector(".bubble").classList.add("bg-blue-600", "text-white", "border-blue-600")
      element.querySelector(".bubble").classList.remove("bg-white", "border-gray-200")
    }

    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  setConnected(connected) {
    this.inputTarget.disabled = !connected
    this.buttonTarget.disabled = !connected
    this.statusTarget.textContent = connected ? "Connected" : "Reconnecting…"
    if (connected) this.inputTarget.focus()
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.toggle("hidden", message === "")
  }
}
