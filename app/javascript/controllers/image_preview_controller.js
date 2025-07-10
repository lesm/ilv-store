import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['image', 'source'];

  show() {
    const reader = new FileReader();

    reader.onload = () => {
      this.imageTarget.src = reader.result;
    };

    reader.readAsDataURL(this.sourceTarget.files[0]);
  }
}
