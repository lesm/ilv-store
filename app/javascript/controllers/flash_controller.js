import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['flash'];

  connect() {
    this.mobileWindow = window.innerWidth <= 767;

    if (this.mobileWindow) {
      this.element.classList.remove('bottom-30');
      this.element.classList.add('top-20');
    }

    this.timeoutId = setTimeout(() => {
      this.element.remove();
    }, 8300);
  }

  close() {
    clearTimeout(this.timeoutId);
    this.element.remove();
  }
}
