import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "location"]

  connect() {
    this.schools = []
    this.hideResults = this.hideResults.bind(this)
    document.addEventListener('click', this.hideResults)
    this.loadLocations()
  }

  disconnect() {
    document.removeEventListener('click', this.hideResults)
  }

  hideResults(event) {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.classList.add('hidden')
    }
  }

  async loadLocations() {
    try {
      const response = await fetch('/api/schools/locations')
      const locations = await response.json()
      const options = locations.map(loc => `<option value="${loc}">${loc}</option>`).join('')
      this.locationTarget.insertAdjacentHTML('beforeend', options)
    } catch (error) {
      console.error('Failed to load locations:', error)
    }
  }

  async selectLocation() {
    const location = this.locationTarget.value

    this.inputTarget.value = ''
    this.resultsTarget.classList.add('hidden')

    if (!location) {
      this.schools = []
      this.inputTarget.disabled = true
      return
    }

    try {
      const response = await fetch(`/api/schools?location=${encodeURIComponent(location)}`)
      this.schools = await response.json()
      this.inputTarget.disabled = false
      this.inputTarget.placeholder = `${this.schools.length}개 학교에서 검색...`
      this.inputTarget.focus()
    } catch (error) {
      console.error('Failed to load schools:', error)
    }
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase()

    if (query.length < 1) {
      this.resultsTarget.classList.add('hidden')
      return
    }

    const filtered = this.schools.filter(school =>
      school.name.toLowerCase().includes(query)
    )
    this.renderResults(filtered)
  }

  renderResults(schools) {
    if (schools.length === 0) {
      this.resultsTarget.innerHTML = `
        <li class="px-6 py-4 text-slate-500">검색 결과가 없습니다</li>
      `
    } else {
      this.resultsTarget.innerHTML = schools.map(school => `
        <li>
          <a href="/schools/${school.id}"
             class="block px-6 py-4 hover:bg-blue-500/8 transition-all"
             data-action="click->school-search#selectSchool"
             data-school-id="${school.id}"
             data-school-name="${school.name}">
            <div class="font-medium text-slate-200">${school.name}</div>
            ${school.location ? `<div class="text-sm text-slate-500">${school.location}</div>` : ''}
          </a>
        </li>
      `).join('')
    }
    this.resultsTarget.classList.remove('hidden')
  }

  selectSchool(event) {
    const schoolId = event.currentTarget.dataset.schoolId
    const schoolName = event.currentTarget.dataset.schoolName
    this.saveRecentSchool({ id: schoolId, name: schoolName })
  }

  saveRecentSchool(school) {
    const recent = JSON.parse(localStorage.getItem('recentSchools') || '[]')
    const filtered = recent.filter(s => s.id !== school.id)
    filtered.unshift(school)
    localStorage.setItem('recentSchools', JSON.stringify(filtered.slice(0, 5)))
  }
}
