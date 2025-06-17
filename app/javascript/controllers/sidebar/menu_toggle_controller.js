import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu', 'asidebar'];

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
  }

  toggle() {
    this.asidebarTarget.classList.toggle('-translate-x-full');
    this.menuTarget.classList.toggle('hidden');

    if (!this.asidebarTarget.classList.contains('-translate-x-full')) {
      document.addEventListener('click', this.handleClickOutside)
    } else {
      document.removeEventListener('click', this.handleClickOutside)
    }
  }

  handleClickOutside(event) {
    if (!this.asidebarTarget.contains(event.target) && !this.menuTarget.contains(event.target)) {
      this.asidebarTarget.classList.toggle('-translate-x-full');
      this.menuTarget.classList.toggle('hidden');
      document.removeEventListener('click', this.handleClickOutside)
    }
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside)
  }
}
