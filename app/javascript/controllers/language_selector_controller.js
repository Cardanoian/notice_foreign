import { Controller } from "@hotwired/stimulus"

const LANGUAGES = [
  { code: "ko", label: "한국어" },
  { code: "en", label: "English" },
  { code: "zh", label: "中文" },
  { code: "vi", label: "Tiếng Việt" },
  { code: "ja", label: "日本語" },
  { code: "es", label: "Español" },
]

const STORAGE_KEY = "selected_language"

function setCookie(name, value, days) {
  const expires = new Date(Date.now() + days * 864e5).toUTCString()
  document.cookie = `${name}=${value};expires=${expires};path=/;SameSite=Lax`
}

function getCookie(name) {
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`))
  return match ? match[1] : null
}

export default class extends Controller {
  static targets = ["current", "menu"]

  connect() {
    this.selectedLang = getCookie("lang") || localStorage.getItem(STORAGE_KEY) || "ko"
    this.updateLabel()
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    const lang = event.currentTarget.dataset.lang
    localStorage.setItem(STORAGE_KEY, lang)
    setCookie("lang", lang, 365)
    this.selectedLang = lang
    this.updateLabel()
    this.menuTarget.classList.add("hidden")

    const url = new URL(window.location.href)
    url.searchParams.set('lang', lang)
    Turbo.visit(url.toString())
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  updateLabel() {
    const lang = LANGUAGES.find(l => l.code === this.selectedLang)
    this.currentTarget.textContent = lang ? lang.label : "한국어"
  }

  get languages() {
    return LANGUAGES
  }
}
