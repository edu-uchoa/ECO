import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "iconOpen", "iconClose"]

  connect() {
    // Close menu when clicking outside the navbar
    this._outsideClickHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    }
    document.addEventListener("click", this._outsideClickHandler)

    // Close menu on Turbo navigation
    document.addEventListener("turbo:before-visit", () => this.close())
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClickHandler)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.iconOpenTarget.classList.add("hidden")
    this.iconCloseTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.iconOpenTarget.classList.remove("hidden")
    this.iconCloseTarget.classList.add("hidden")
  }
}
