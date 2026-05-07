import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "modal", "nameInput", "nameError", "submitButton"]

  static values = {
    canCreate: Boolean,
    isAuth: Boolean,
    pointsUrl: String,
    createUrl: String
  }

  connect() {
    this.pendingLat = null
    this.pendingLng = null
    this.map = null
    this.markerIcon = null

    this.initMap()
  }

  disconnect() {
    this.destroyMap()
  }

  closeModal() {
    if (this.hasModalTarget) {
      this.modalTarget.style.display = "none"
    }
  }

  async submitPoint() {
    const name = (this.nameInputTarget?.value || "").trim()

    if (name.length < 3) {
      this.showError("Min. 3 caracteres.")
      return
    }

    this.showError("")

    if (!this.submitButtonTarget) return

    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Salvando..."

    try {
      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({
          collection_point: {
            name,
            latitude: this.pendingLat,
            longitude: this.pendingLng
          }
        })
      })

      const data = await response.json()

      if (response.status === 201) {
        this.addMarker(data)
        this.closeModal()
      } else {
        this.showError(data?.error || "Erro.")
      }
    } catch (_error) {
      this.showError("Erro de conexão.")
    } finally {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Salvar"
    }
  }

  async initMap() {
    if (!this.hasCanvasTarget) return

    const leafletReady = await this.waitForLeaflet()
    if (!leafletReady) {
      this.renderMapError("Não foi possível carregar o mapa agora. Recarregue a página.")
      return
    }

    this.destroyMap()

    this.map = window.L.map(this.canvasTarget).setView([-15.7801, -47.9292], 5)

    window.L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", { maxZoom: 19 }).addTo(this.map)

    this.markerIcon = window.L.divIcon({
      className: "",
      html: '<div style="width:12px;height:12px;background:#16a34a;border:2px solid white;border-radius:50%;box-shadow:0 2px 4px rgba(0,0,0,0.4);"></div>',
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })

    this.map.on("click", (event) => this.handleMapClick(event))

    await this.loadPoints()
  }

  destroyMap() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  async waitForLeaflet(maxRetries = 40, delayMs = 50) {
    for (let i = 0; i < maxRetries; i += 1) {
      if (window.L) return true
      await new Promise((resolve) => setTimeout(resolve, delayMs))
    }

    return false
  }

  async loadPoints() {
    try {
      const response = await fetch(this.pointsUrlValue)
      const points = await response.json()

      points.forEach((point) => this.addMarker(point))
    } catch (_error) {
      // Ignore and keep map usable even if points fail.
    }
  }

  addMarker(point) {
    if (!this.map || !window.L) return

    window.L.marker([point.latitude, point.longitude], { icon: this.markerIcon })
      .addTo(this.map)
      .bindPopup(`<b>${point.name}</b><br><small>${point.user}</small>`)
  }

  handleMapClick(event) {
    if (!this.isAuthValue) {
      window.alert("Faça login para adicionar pontos.")
      return
    }

    if (!this.canCreateValue) {
      window.alert("Complete seu perfil para adicionar pontos.")
      return
    }

    this.pendingLat = event.latlng.lat
    this.pendingLng = event.latlng.lng

    if (this.hasNameInputTarget) {
      this.nameInputTarget.value = ""
      this.nameInputTarget.focus()
    }

    this.showError("")

    if (this.hasModalTarget) {
      this.modalTarget.style.display = "flex"
    }
  }

  showError(message) {
    if (!this.hasNameErrorTarget) return

    if (message) {
      this.nameErrorTarget.textContent = message
      this.nameErrorTarget.style.display = "block"
    } else {
      this.nameErrorTarget.textContent = ""
      this.nameErrorTarget.style.display = "none"
    }
  }

  renderMapError(message) {
    this.canvasTarget.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#6b7280;font-size:14px;padding:16px;text-align:center;">${message}</div>`
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute("content") : ""
  }
}