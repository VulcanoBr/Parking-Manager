// app/javascript/controllers/parking_form_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'selectedSpotInfo',
    'noSpotsInfo',
    'spotIdentification',
    'spotMessage',
    'noSpotsMessage',
    'parkingSpotId',
    'submitBtn'
  ]

  static values = {
    parkingLotId: Number,
    carSpotsCount: Number,
    motorcycleSpotsCount: Number
  }

  connect() {
    console.log('Parking form controller connected')

    // Auto-selecionar o primeiro tipo disponível
    this.autoSelectVehicleType()
  }

  updateSpot(event) {
    const vehicleType = event.target.value

    if (!vehicleType) return

    this.fetchNextAvailableSpot(vehicleType)
  }

  async fetchNextAvailableSpot(vehicleType) {
    try {
      // Reset display
      this.hideAllInfos()

      const url = `/parking_lots/${this.parkingLotIdValue}/parking_records/next_available_spot`
      const params = new URLSearchParams({ vehicle_type: vehicleType })

      const response = await fetch(`${url}?${params}`, {
        method: 'GET',
        headers: {
          Accept: 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.getCsrfToken()
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      if (data.success) {
        this.showSpotAvailable(data)
      } else {
        this.showNoSpotsAvailable(data)
      }
    } catch (error) {
      this.showError()
    }
  }

  showSpotAvailable(data) {
    this.spotIdentificationTarget.textContent = `Vaga ${data.spot.identification}`
    this.spotMessageTarget.textContent = data.message
    this.parkingSpotIdTarget.value = data.spot.id

    this.selectedSpotInfoTarget.classList.remove('d-none')
    this.selectedSpotInfoTarget.classList.add('fade-in')
    this.noSpotsInfoTarget.classList.add('d-none')

    this.submitBtnTarget.disabled = false
  }

  showNoSpotsAvailable(data) {
    this.noSpotsMessageTarget.textContent = data.message
    this.parkingSpotIdTarget.value = ''

    this.noSpotsInfoTarget.classList.remove('d-none')
    this.noSpotsInfoTarget.classList.add('fade-in')
    this.selectedSpotInfoTarget.classList.add('d-none')

    this.submitBtnTarget.disabled = true
  }

  showError() {
    this.noSpotsMessageTarget.textContent =
      'Erro ao verificar vagas disponíveis'
    this.noSpotsInfoTarget.classList.remove('d-none')
    this.selectedSpotInfoTarget.classList.add('d-none')
    this.submitBtnTarget.disabled = true
  }

  hideAllInfos() {
    this.selectedSpotInfoTarget.classList.add('d-none')
    this.noSpotsInfoTarget.classList.add('d-none')
  }

  autoSelectVehicleType() {
    // Aguardar um pouco para garantir que o DOM está pronto
    setTimeout(() => {
      if (this.carSpotsCountValue > 0) {
        const carRadio = this.element.querySelector('input[value="car"]')
        if (carRadio) {
          carRadio.checked = true
          this.fetchNextAvailableSpot('car')
        }
      } else if (this.motorcycleSpotsCountValue > 0) {
        const motorcycleRadio = this.element.querySelector(
          'input[value="motorcycle"]'
        )
        if (motorcycleRadio) {
          motorcycleRadio.checked = true
          this.fetchNextAvailableSpot('motorcycle')
        }
      } else {
        this.submitBtnTarget.disabled = true
        this.noSpotsMessageTarget.textContent =
          'Não há vagas disponíveis no momento'
        this.noSpotsInfoTarget.classList.remove('d-none')
      }
    }, 100)
  }

  getCsrfToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }
}
