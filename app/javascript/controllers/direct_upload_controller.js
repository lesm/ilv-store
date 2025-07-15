import { Controller } from '@hotwired/stimulus';
import { DirectUpload } from '@rails/activestorage';

export default class extends Controller {
  static targets = ['input', 'progressBar'];

  now() {
    Array.from(this.inputTarget.files).forEach(file => this.#uploadFile(file));
  }

  #uploadFile(file) {
    const url = this.inputTarget.dataset.directUploadUrl;
    const upload = new DirectUpload(file, url, this);

    upload.create((error, blob) => {
      if (error) {
      } else {
        this.#createHiddenInput(blob);
      }
    })
  }

  #createHiddenInput(blob) {
    const hiddenField = document.createElement('input');

    hiddenField.setAttribute('id', `attachment_${blob.filename}`);
    hiddenField.setAttribute('type', 'hidden');
    hiddenField.setAttribute('value', blob.signed_id);
    hiddenField.name = this.inputTarget.name;

    this.element.appendChild(hiddenField);
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener('progress', (event) => {
      this.#progressUpdate(event);
    })
  }

  #progressUpdate(event) {
    const progress = (event.loaded / event.total) * 100;

    this.progressBarTargets.forEach((progressBar) => {
      progressBar.style.width = `${progress}%`;
    })
  }
}
