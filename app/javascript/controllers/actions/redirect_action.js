import { Turbo } from '@hotwired/turbo-rails'

Turbo.StreamActions.redirect = function () {
  console.log('Redirecting to target:', this.getAttribute('target'))
  Turbo.visit(this.getAttribute('target'))
}
