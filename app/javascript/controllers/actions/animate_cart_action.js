import { Turbo } from '@hotwired/turbo-rails'

Turbo.StreamActions.animate_cart = function () {
  const id = this.getAttribute('target')
  const element = document.getElementById(id)
  if (element) {
    element.classList.add('animate-cart')
    setTimeout(() => {
      element.classList.remove('animate-cart')
    }, 1000)
  }
}
