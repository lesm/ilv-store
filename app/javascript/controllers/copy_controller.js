import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy"
export default class extends Controller {
  static targets = ["copyIcon", "checkIcon", "source"]
  static values = {
    text: String,
    feedbackDuration: { type: Number, default: 2000 }
  }

  copy(event) {
    event.preventDefault()

    // Get text from value or from source target
    const textToCopy = this.textValue || this.sourceTarget.textContent.trim()

    navigator.clipboard.writeText(textToCopy)
      .then(() => {
        this.showSuccess()
      })
      .catch((error) => {
        console.error("Failed to copy text:", error)
      })
  }

  showSuccess() {
    // Only swap icons if both targets exist
    if (this.hasCopyIconTarget && this.hasCheckIconTarget) {
      this.copyIconTarget.classList.add("hidden")
      this.checkIconTarget.classList.remove("hidden")

      setTimeout(() => {
        this.copyIconTarget.classList.remove("hidden")
        this.checkIconTarget.classList.add("hidden")
      }, this.feedbackDurationValue)
    }

    // Dispatch custom event for other feedback mechanisms
    this.dispatch("copied", { detail: { text: this.textValue } })
  }
}
