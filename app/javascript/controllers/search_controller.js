import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading"]
  static values = {
    debounce: { type: Number, default: 300 },
    query: { type: String, default: '' }
  }

  connect() {
    this.timeout = null
    this.currentQuery = this.queryValue
    this.autoFocusInput()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  instantSearch() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query === this.currentQuery) return

    this.currentQuery = query
    this.showLoading()
    this.timeout = setTimeout(() => this.performSearch(query), this.debounceValue)
  }

  search(event) {
    event.preventDefault()
    this.currentQuery = this.inputTarget.value.trim()
    this.performSearch(this.currentQuery)
  }

  async performSearch(query) {
    try {
      const url = this.buildSearchUrl(query)
      this.updateBrowserUrl(url, query)

      const html = await this.fetchSearchResults(url)
      this.updateResults(html)
      this.reinitializeInfiniteScroll()
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      this.hideLoading()
    }
  }

  buildSearchUrl(query) {
    const locale = this.getCurrentLocale()
    const params = new URLSearchParams({ q: query })
    return locale ? `/${locale}/products?${params}` : `/products?${params}`
  }

  getCurrentLocale() {
    // Extract locale from current URL path (e.g., /es/products -> 'es')
    const pathParts = window.location.pathname.split('/')
    const potentialLocale = pathParts[1]

    // Check if it's a valid locale (es, en, etc.)
    const validLocales = ['es', 'en']
    return validLocales.includes(potentialLocale) ? potentialLocale : null
  }

  updateBrowserUrl(url, query) {
    window.history.pushState({ query }, '', url)
  }

  async fetchSearchResults(url) {
    const response = await fetch(url, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })

    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
    return response.text()
  }

  updateResults(html) {
    const parser = new DOMParser()
    const doc = parser.parseFromString(html, 'text/html')
    const newResults = doc.querySelector('[data-search-target="results"]')

    if (newResults && this.hasResultsTarget) {
      this.resultsTarget.innerHTML = newResults.innerHTML
    }
  }

  reinitializeInfiniteScroll() {
    const infiniteScrollController = this.application.getControllerForElementAndIdentifier(
      this.element,
      'infinite-scroll'
    )
    infiniteScrollController?.initObserver?.()
  }

  autoFocusInput() {
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  showLoading() {
    if (!this.hasLoadingTarget || !this.hasResultsTarget) return
    this.resultsTarget.classList.add('hidden')
    this.loadingTarget.classList.remove('hidden')
  }

  hideLoading() {
    if (!this.hasLoadingTarget || !this.hasResultsTarget) return
    this.loadingTarget.classList.add('hidden')
    this.resultsTarget.classList.remove('hidden')
  }
}
