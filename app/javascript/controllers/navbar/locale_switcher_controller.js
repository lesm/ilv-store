import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "esLink", "enLink"]
  static values = {
    locales: { type: Array, default: ['es', 'en'] }
  }

  connect() {
    this.updateLinks()
    this.handlePopstate = this.updateLinks.bind(this)
    window.addEventListener('popstate', this.handlePopstate)
  }

  disconnect() {
    window.removeEventListener('popstate', this.handlePopstate)
  }

  toggle(event) {
    event.stopPropagation()
    this.updateLinks()
    this.dropdownTarget.classList.toggle("hidden")
  }

  outsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  hide() {
    this.dropdownTarget.classList.add("hidden")
  }

  updateLinks() {
    const { pathname, search } = window.location
    const searchParams = new URLSearchParams(search)
    const basePath = this.getBasePathWithoutLocale(pathname)

    if (this.hasEsLinkTarget) {
      this.esLinkTarget.href = this.buildLocaleUrl('es', basePath, searchParams)
    }
    if (this.hasEnLinkTarget) {
      this.enLinkTarget.href = this.buildLocaleUrl('en', basePath, searchParams)
    }
  }

  getBasePathWithoutLocale(pathname) {
    const parts = pathname.split('/').filter(Boolean)

    // Remove locale from path if present
    if (parts.length > 0 && this.localesValue.includes(parts[0])) {
      parts.shift()
    }

    return parts.join('/')
  }

  buildLocaleUrl(locale, basePath, searchParams) {
    const url = new URL(window.location.origin)

    // Root path uses query param, other paths use prefix
    if (basePath === '') {
      url.pathname = '/'
      url.searchParams.set('locale', locale)
    } else {
      url.pathname = `/${locale}/${basePath}`
    }

    // Copy query params (excluding locale)
    for (const [key, value] of searchParams) {
      if (key !== 'locale') {
        url.searchParams.set(key, value)
      }
    }

    return url.toString()
  }
}
