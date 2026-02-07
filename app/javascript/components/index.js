import React from 'react'
import { createRoot } from 'react-dom/client'

const componentRegistry = {}
const rootMap = new WeakMap()

export function registerComponent(name, component) {
  componentRegistry[name] = component
}

export function mountComponents() {
  document.querySelectorAll('[data-react-component]').forEach(node => {
    const name = node.dataset.reactComponent
    const props = node.dataset.reactProps ? JSON.parse(node.dataset.reactProps) : {}
    const Component = componentRegistry[name]

    if (!Component) return

    let root = rootMap.get(node)
    if (!root) {
      root = createRoot(node)
      rootMap.set(node, root)
    }
    root.render(React.createElement(Component, props))
  })
}

document.addEventListener('turbo:load', mountComponents)
