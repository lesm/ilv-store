import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static targets = ["pagination", "scrollSentinel"]
  static values = { loading: Boolean }

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersection(entries),
      {
        threshold: 0.1,
        rootMargin: "100px"
      }
    )

    if (this.hasScrollSentinelTarget) {
      this.observer.observe(this.scrollSentinelTarget)
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  // Called when scrollSentinel target is added to the DOM
  scrollSentinelTargetConnected(element) {
    if (this.observer) {
      this.observer.observe(element)
    }
  }

  // Called when scrollSentinel target is removed from the DOM
  scrollSentinelTargetDisconnected(element) {
    if (this.observer) {
      this.observer.unobserve(element)
    }
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && !this.loadingValue) {
        this.loadMore()
      }
    })
  }

  loadMore() {
    const nextLink = this.paginationTarget.querySelector("a[rel='next']")

    if (!nextLink) return

    this.loadingValue = true

    fetch(nextLink.href, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
        this.loadingValue = false
      })
      .catch(() => {
        this.loadingValue = false
      })
  }
}
