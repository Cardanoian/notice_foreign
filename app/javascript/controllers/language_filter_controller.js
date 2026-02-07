import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { schoolId: Number }

  filter(event) {
    const lang = event.currentTarget.dataset.lang
    const url = lang ? `/schools/${this.schoolIdValue}?lang=${lang}` : `/schools/${this.schoolIdValue}`
    
    event.currentTarget.parentElement.querySelectorAll('button').forEach(btn => {
      btn.classList.remove('bg-blue-100', 'text-blue-700')
      btn.classList.add('bg-gray-100', 'text-gray-700')
    })
    event.currentTarget.classList.remove('bg-gray-100', 'text-gray-700')
    event.currentTarget.classList.add('bg-blue-100', 'text-blue-700')
    
    Turbo.visit(url)
  }
}
