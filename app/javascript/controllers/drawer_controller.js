import { Controller } from '@hotwired/stimulus';
import { enter, leave } from 'el-transition';

export default class extends Controller {
  static targets = ['backdrop', 'panel', 'closeLink'];

  #isEntering;
  #isLeaving;

  connect() {
    this.element.addEventListener('click', this.handleClickOutside);
    this.element.addEventListener('keydown', this.handleEscape);
  }

  disconnect() {
    this.element.removeEventListener('click', this.handleClickOutside);
    this.element.removeEventListener('keydown', this.handleEscape);
  }

  backdropTargetConnected(target) {
    if (this.#isEntering) enter(target);
  }

  panelTargetConnected(target) {
    if (this.#isEntering) enter(target);

    // Make the drawer focus when it's opened (to ESC key works)
    this.element.setAttribute('tabindex', '-1');
    this.element.focus();
  }

  handleClickOutside = (e) => {
    // Prevent bubble click event when we manually close the drawer (this._closeDrawer())
    if (this._isClosing) {
      return;
    }

    // Ignore click event when user clicks the close link drawer
    if (this.closeLinkTarget.contains(e.target)) {
      return;
    }

    // Ignore clicks on select dropdowns and their options
    if (e.target.tagName === 'SELECT' || e.target.tagName === 'OPTION') {
      return;
    }

    const drawer = this.panelTarget.getBoundingClientRect();
    if (
      e.clientX < drawer.left ||
        e.clientX > drawer.right ||
        e.clientY < drawer.top ||
        e.clientY > drawer.bottom
    ) {
      this._closeDrawer();
    }
  };

  handleEscape = (e) => {
    if (e.key === 'Escape') {
      this._closeDrawer();
    }
  };

  _closeDrawer() {
    this._isClosing = true;
    this.closeLinkTarget.click();
  }

  hideSidebar() {
    const sidebar = document.getElementById('sidebar');

    sidebar.classList.toggle('-translate-x-full');
    sidebar.classList.toggle('hidden');
  }

  async animate(event) {
    const {
      detail: { newFrame },
    } = event;

    const currentChildCount = this.element.children.length;
    const newChildCount = newFrame.children.length;

    this.#isEntering = currentChildCount == 0 && newChildCount > 0;
    this.#isLeaving = currentChildCount > 0 && newChildCount == 0;

    if (this.#isLeaving) {
      this._isClosing = false;
      event.preventDefault();

      await Promise.all([
        leave(this.backdropTarget).then(() => this.backdropTarget.remove()),
        leave(this.panelTarget).then(() => this.panelTarget.remove()),
      ]);

      event.detail.resume();
    }
  }
}
