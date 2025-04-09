import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];

  restrictToNumbers(event) {
    const onlyDigits = event.target.value.replace(/\D|0/g, "")
    event.target.value = onlyDigits
  }

  increment(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value, 10) || 0;
    this.inputTarget.value = currentValue + 1;
  }

  decrement(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value, 10) || 1;
    this.inputTarget.value = Math.max(currentValue - 1, 1); // Prevent negative values;
  }
}
