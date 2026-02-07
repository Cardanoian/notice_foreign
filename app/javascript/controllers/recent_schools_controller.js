import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]
  static values = { noSchools: String }

  connect() {
    this.render()
  }

  render() {
    const recent = JSON.parse(localStorage.getItem('recentSchools') || '[]')
    
    if (recent.length === 0) {
      this.listTarget.innerHTML = `
        <p class="text-white text-sm">${this.noSchoolsValue}</p>
      `
      return
    }

    this.listTarget.innerHTML = recent.map(school => `
      <a href="/schools/${school.id}" 
         class="block p-4 rounded-xl border border-white/6 bg-white/[0.03] hover:bg-white/[0.06] hover:border-blue-500/20 transition-all duration-300 hover:-translate-y-0.5">
        <div class="font-medium text-slate-200">${school.name}</div>
      </a>
    `).join('')
  }
}
