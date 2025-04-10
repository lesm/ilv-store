import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['dropdown']

  toggle() {
    this.dropdownTarget.classList.toggle('hidden');
  }

  outsideClick(e) {
    if (!this.element.contains(e.target)) {
      this.dropdownTarget.classList.add('hidden')
    }
  }
}
