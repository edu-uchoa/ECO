import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas",
    "form",
    "searchInput",
    "titleInput",
    "addressInput",
    "latitudeInput",
    "longitudeInput",
    "openingHoursInput",
    "descriptionInput",
    "contactNameInput",
    "contactPhoneInput",
    "contactEmailInput",
    "imagesInput",
    "categoryCheckbox",
    "submitButton",
    "errorBox",
    "successBox"
  ]

  static values = {
    canCreate: Boolean,
    isAuth: Boolean,
    loginUrl: String,
    pointsUrl: String,
    createUrl: String
  }

  connect() {
    this.map = null
    this.markerIcon = null
    this.selectionMarker = null

    this.initMap()
  }

  disconnect() {
    this.destroyMap()
  }

  async submitPoint(event) {
    event.preventDefault()

    if (!this.isAuthValue) {
      const loginUrl = this.loginUrlValue || "/session/new"
      window.location.assign(loginUrl)
      return
    }

    if (!this.canCreateValue) {
      this.showError("Complete seu perfil antes de enviar um ponto de coleta.")
      return
    }

    const title = this.titleInputTarget.value.trim()
    const address = this.addressInputTarget.value.trim()
    const latitude = this.latitudeInputTarget.value.trim()
    const longitude = this.longitudeInputTarget.value.trim()
    const categories = this.selectedCategories()

    if (title.length < 3) {
      this.showError("O nome do ponto precisa ter ao menos 3 caracteres.")
      return
    }

    if (address.length < 5) {
      this.showError("Informe um endereço completo.")
      return
    }

    if (!latitude || !longitude) {
      this.showError("Selecione a localização clicando no mapa ou usando a busca de endereço.")
      return
    }

    if (categories.length === 0) {
      this.showError("Selecione pelo menos uma categoria de item aceito.")
      return
    }

    this.showError("")
    this.showSuccess("")

    if (!this.submitButtonTarget) return

    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Enviando..."

    try {
      const formData = new FormData()

      formData.append("collection_point[title]", title)
      formData.append("collection_point[address]", address)
      formData.append("collection_point[latitude]", latitude)
      formData.append("collection_point[longitude]", longitude)
      formData.append("collection_point[opening_hours]", this.openingHoursInputTarget.value.trim())
      formData.append("collection_point[description]", this.descriptionInputTarget.value.trim())
      formData.append("collection_point[contact_name]", this.contactNameInputTarget.value.trim())
      formData.append("collection_point[contact_phone]", this.contactPhoneInputTarget.value.trim())
      formData.append("collection_point[contact_email]", this.contactEmailInputTarget.value.trim())

      categories.forEach((category) => {
        formData.append("collection_point[categories][]", category)
      })

      Array.from(this.imagesInputTarget.files || []).forEach((file) => {
        formData.append("collection_point[images][]", file)
      })

      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken()
        },
        body: formData
      })

      if (response.redirected) {
        window.location.assign(response.url)
        return
      }

      if (response.status === 401) {
        const loginUrl = this.loginUrlValue || "/session/new"
        window.location.assign(loginUrl)
        return
      }

      const data = await response.json().catch(() => ({}))

      if (response.status === 201) {
        this.showSuccess(data?.message || "Ponto enviado para moderação com sucesso.")
        this.formTarget.reset()
        this.latitudeInputTarget.value = ""
        this.longitudeInputTarget.value = ""

        if (this.selectionMarker) {
          this.map.removeLayer(this.selectionMarker)
          this.selectionMarker = null
        }
      } else {
        this.showError(data?.error || "Erro.")
      }
    } catch (_error) {
      this.showError("Erro de conexão.")
    } finally {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Enviar para moderação"
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
      html: `
        <div style="position:relative;width:34px;height:34px;display:flex;align-items:center;justify-content:center;">
          <div style="position:absolute;width:34px;height:34px;border-radius:50%;background:rgba(22,163,74,0.22);border:2px solid rgba(22,163,74,0.45);"></div>
          <div style="position:relative;width:14px;height:14px;background:#16a34a;border:3px solid #ffffff;border-radius:50%;box-shadow:0 2px 6px rgba(0,0,0,0.45);"></div>
        </div>
      `,
      iconSize: [34, 34],
      iconAnchor: [17, 17],
      popupAnchor: [0, -16]
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

    const title = this.escapeHtml(point.title || "Ponto de coleta")
    const address = this.escapeHtml(point.address || "")
    const categories = Array.isArray(point.categories) ? point.categories.join(", ") : ""
    const firstImage = Array.isArray(point.image_urls) && point.image_urls.length > 0 ? point.image_urls[0] : null
    const imageHtml = firstImage
      ? `<img src="${this.escapeAttribute(firstImage)}" alt="Imagem do ponto" style="display:block;width:100%;max-width:220px;height:120px;object-fit:cover;border-radius:8px;margin:6px 0;" loading="lazy" />`
      : ""

    const popup = [
      `<b>${title}</b>`,
      imageHtml,
      address ? `<div style="margin-top:4px;">${this.escapeHtml(address)}</div>` : "",
      point.opening_hours ? `<small>Horário: ${this.escapeHtml(point.opening_hours)}</small>` : "",
      categories ? `<small>Categorias: ${this.escapeHtml(categories)}</small>` : "",
      point.user ? `<small>Enviado por: ${this.escapeHtml(point.user)}</small>` : ""
    ].filter(Boolean).join("<br>")

    window.L.marker([point.latitude, point.longitude], { icon: this.markerIcon })
      .addTo(this.map)
      .bindPopup(popup)
  }

  handleMapClick(event) {
    this.setSelectedLocation(event.latlng.lat, event.latlng.lng)
  }

  async searchAddress() {
    const query = this.searchInputTarget.value.trim()

    if (!query) {
      this.showError("Digite um endereço para pesquisar.")
      return
    }

    this.showError("")

    try {
      const params = new URLSearchParams({
        q: query,
        format: "json",
        limit: "1"
      })

      const response = await fetch(`https://nominatim.openstreetmap.org/search?${params.toString()}`, {
        headers: {
          Accept: "application/json"
        }
      })

      const results = await response.json()

      if (!Array.isArray(results) || results.length === 0) {
        this.showError("Endereço não encontrado. Tente um termo mais completo.")
        return
      }

      const place = results[0]
      const lat = Number(place.lat)
      const lng = Number(place.lon)

      if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
        this.showError("Não foi possível localizar esse endereço no mapa.")
        return
      }

      this.map.setView([lat, lng], 15)
      this.setSelectedLocation(lat, lng)

      if (!this.addressInputTarget.value.trim()) {
        this.addressInputTarget.value = place.display_name || query
      }
    } catch (_error) {
      this.showError("Falha ao pesquisar endereço. Tente novamente em instantes.")
    }
  }

  setSelectedLocation(latitude, longitude) {
    if (!this.map || !window.L) return

    const lat = Number(latitude)
    const lng = Number(longitude)

    this.latitudeInputTarget.value = lat.toFixed(6)
    this.longitudeInputTarget.value = lng.toFixed(6)

    if (this.selectionMarker) {
      this.map.removeLayer(this.selectionMarker)
    }

    this.selectionMarker = window.L.marker([lat, lng]).addTo(this.map)
    this.selectionMarker.bindPopup("Localização selecionada para submissão").openPopup()
  }

  selectedCategories() {
    return this.categoryCheckboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value)
  }

  showError(message) {
    if (!this.hasErrorBoxTarget) return

    if (message) {
      this.errorBoxTarget.textContent = message
      this.errorBoxTarget.classList.remove("hidden")
    } else {
      this.errorBoxTarget.textContent = ""
      this.errorBoxTarget.classList.add("hidden")
    }
  }

  showSuccess(message) {
    if (!this.hasSuccessBoxTarget) return

    if (message) {
      this.successBoxTarget.textContent = message
      this.successBoxTarget.classList.remove("hidden")
    } else {
      this.successBoxTarget.textContent = ""
      this.successBoxTarget.classList.add("hidden")
    }
  }

  renderMapError(message) {
    this.canvasTarget.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#6b7280;font-size:14px;padding:16px;text-align:center;">${message}</div>`
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute("content") : ""
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;")
  }

  escapeAttribute(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll('"', "&quot;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
  }
}