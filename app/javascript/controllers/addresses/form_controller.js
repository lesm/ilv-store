import { Controller } from '@hotwired/stimulus';
import { get } from '@rails/request.js';

export default class extends Controller {
  static targets = ['postalCode', 'stateId', 'stateName', 'cityId', 'cityName', 'neighborhood'];

  restrictToNumbers(event) {
    const onlyDigits = event.target.value.replace(/\D/g, "")
    event.target.value = onlyDigits
  }

  async completeAddress() {
    if (this.postalCodeTarget.value.length === 5) {
      const response = await get('/postal_codes.json',
        { query: { postal_code: this.postalCodeTarget.value }, dataType: 'json' }
      );

      if (response.ok) {
        const data = await response.json;

        this.stateIdTarget.value = data.state.id;
        this.stateNameTarget.value = data.state.name;
        this.cityIdTarget.value = data.city.id;
        this.cityNameTarget.value = data.city.name;

        this.createSelectOptions(data.neighborhoods);
      } else if (response.statusCode === 404) {
        const message = `No se encontrarón datos para el código postal ${this.postalCodeTarget.value}`;
        this.createFlashMessage(message);
      } else if (response.statusCode === 500) {
        const message = `Error al buscar el código postal ${this.postalCodeTarget.value} intente nuevamente`;
        this.createFlashMessage(message);
      }
    }
  }

  createFlashMessage(message) {
    const template = document.getElementById('alertTemplate').content.cloneNode(true);
    template.querySelector('.error-message').innerText = message;
    this.element.appendChild(template);
  }

  createSelectOptions(neighborhoods) {
    const frag = document.createDocumentFragment();

    this.createOptions(frag, neighborhoods);
    this.neighborhoodTarget.innerHTML = '';
    this.neighborhoodTarget.appendChild(frag);
  }

  createOptions(frag, neighborhoods) {
    const firstNeighborhood = neighborhoods.shift();

    const option = this.createOption(firstNeighborhood, true);
    frag.appendChild(option);

    neighborhoods.forEach(neighborhood => {
      const option = this.createOption(neighborhood, false);
      frag.appendChild(option);
    });
  }

  createOption(neighborhood, selected = false) {
    const option = document.createElement('option');
    option.value = neighborhood;
    option.innerText = neighborhood;
    option.selected = selected;

    return option;
  }
}
