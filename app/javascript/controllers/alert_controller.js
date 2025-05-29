import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    console.log('Alert connected')
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    this.element.classList.remove('show')
    setTimeout(() => {
      this.element.remove()
    }, 150)
  }
}
