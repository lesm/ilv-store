import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['compact', 'expanded']

  connect() {
    console.log('Details controller connected');
  }

  toggle() {
    this.compactTarget.classList.toggle('hidden')
    this.expandedTarget.classList.toggle('hidden')
  }
}
