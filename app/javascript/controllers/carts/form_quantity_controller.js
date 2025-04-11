import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];

  increment(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value, 10) || 0;
    this.inputTarget.value = currentValue + 1;
    this.submit();
  }

  decrement(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value, 10) || 1;
    this.inputTarget.value = Math.max(currentValue - 1, 1); // Prevent negative values;
    this.submit();
  }

  submit() {
    this.element.requestSubmit();
  }
}
