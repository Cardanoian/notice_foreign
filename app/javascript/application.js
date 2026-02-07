import "@hotwired/turbo-rails"
import "./controllers"
import { registerComponent, mountComponents } from "./components"
import RemarkViewer from "./components/RemarkViewer"

registerComponent('RemarkViewer', RemarkViewer)
