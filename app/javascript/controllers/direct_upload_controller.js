import { Controller } from '@hotwired/stimulus';
import { DirectUpload } from '@rails/activestorage';

export default class extends Controller {
  static targets = ['input', 'progressBar'];

  now() {
    Array.from(this.inputTarget.files).forEach(file => this.#uploadFile(file));
    this.inputTargets.forEach(input => input.value = null);
  }

  #uploadFile(file) {
    this.#toggleSubmitButton();

    const url = this.inputTarget.dataset.directUploadUrl;
    const upload = new DirectUpload(file, url, this);

    upload.create((error, blob) => {
      if (error) {
        this.#createErrorMessage(file);
      } else {
        this.#createHiddenInput(blob);
        this.#toggleSubmitButton(false);
      }
    })
  }

  #toggleSubmitButton(disabled = true) {
    const submitButton = this.element.closest('form').querySelector('input[type="submit"]');
    if (submitButton) {
      submitButton.disabled = disabled;
    }
  }

  #createErrorMessage(file) {
    const message = `Error al subir el archivo ${file.name}, intente nuevamente.`;
    const span = document.createElement('span');
    span.classList.add('text-xs', 'text-red-500');
    span.innerText = message;
    this.element.appendChild(span);
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
