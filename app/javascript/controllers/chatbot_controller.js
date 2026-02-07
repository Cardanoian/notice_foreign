import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input"]
  static values = { docId: Number, errorPrefix: String, serverError: String }

  connect() {
    this.loadHistory()
  }

  loadHistory() {
    const history = this.getHistory()
    if (history.length > 0) {
      this.messagesTarget.innerHTML = ''
      history.forEach(msg => this.appendMessage(msg.role, msg.content))
    }
  }

  getHistory() {
    const key = `chat_history_${this.docIdValue}`
    return JSON.parse(localStorage.getItem(key) || '[]')
  }

  saveHistory(history) {
    const key = `chat_history_${this.docIdValue}`
    localStorage.setItem(key, JSON.stringify(history.slice(-20)))
  }

  async send(event) {
    event.preventDefault()
    
    const message = this.inputTarget.value.trim()
    if (!message) return

    this.inputTarget.value = ''
    this.appendMessage('user', message)
    
    const history = this.getHistory()
    history.push({ role: 'user', content: message })

    this.appendMessage('assistant', '...', true)

    try {
      const response = await fetch(`/api/docs/${this.docIdValue}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ message })
      })

      const data = await response.json()
      
      this.removeLoading()
      
      if (data.error) {
        this.appendMessage('assistant', `${this.errorPrefixValue}: ${data.error}`)
      } else {
        this.appendMessage('assistant', data.response)
        history.push({ role: 'assistant', content: data.response })
      }
    } catch (error) {
      this.removeLoading()
      this.appendMessage('assistant', this.serverErrorValue)
    }

    this.saveHistory(history)
  }

  appendMessage(role, content, isLoading = false) {
    const isUser = role === 'user'
    const messageHtml = `
      <div class="flex ${isUser ? 'justify-end' : 'justify-start'} ${isLoading ? 'loading-message' : ''}">
        <div class="${isUser ? 'chat-user' : 'chat-ai'} text-sm">
          ${isLoading ? '<span class="typing-indicator"><span></span><span></span><span></span></span>' : content}
        </div>
      </div>
    `
    this.messagesTarget.insertAdjacentHTML('beforeend', messageHtml)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  removeLoading() {
    const loading = this.messagesTarget.querySelector('.loading-message')
    if (loading) loading.remove()
  }
}
