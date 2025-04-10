import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.timeoutId = setTimeout(() => {
      this.element.remove();
    }, 9200);
  }

  close() {
    clearTimeout(this.timeoutId);
    this.element.remove();
  }
}
