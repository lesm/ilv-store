import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['compact', 'expanded']

  toggle() {
    this.compactTarget.classList.toggle('hidden')
    this.expandedTarget.classList.toggle('hidden')
  }
}
