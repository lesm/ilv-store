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
    const textToCopy = this.textValue || (this.hasSourceTarget ? this.sourceTarget.textContent.trim() : "")

    // Try modern Clipboard API first
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(textToCopy)
        .then(() => {
          this.showSuccess()
        })
        .catch((error) => {
          console.error("Failed to copy text:", error)
          // Fallback for iOS
          this.fallbackCopy(textToCopy)
        })
    } else {
      // Fallback for older browsers/iOS
      this.fallbackCopy(textToCopy)
    }
  }

  fallbackCopy(text) {
    const textArea = document.createElement("textarea")
    textArea.value = text
    textArea.style.position = "fixed"
    textArea.style.left = "-999999px"
    textArea.style.top = "-999999px"
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      const successful = document.execCommand('copy')
      if (successful) {
        this.showSuccess()
      }
    } catch (error) {
      console.error('Fallback copy failed:', error)
    }

    document.body.removeChild(textArea)
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
