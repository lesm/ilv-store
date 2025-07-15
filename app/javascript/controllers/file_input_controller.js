import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('turbo:submit-end', this.enableFileInputs.bind(this))
  }

  enableFileInputs() {
    const fileInputs = this.element.querySelectorAll('input[type="file"][disabled]')
    fileInputs.forEach(input => {
      input.disabled = false
    })
  }
}
