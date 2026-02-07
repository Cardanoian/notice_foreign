import { Application } from "@hotwired/stimulus"
import HelloController from "./hello_controller"
import SchoolSearchController from "./school_search_controller"
import RecentSchoolsController from "./recent_schools_controller"
import ChatbotController from "./chatbot_controller"
import LanguageFilterController from "./language_filter_controller"
import LanguageSelectorController from "./language_selector_controller"

const application = Application.start()
application.register("hello", HelloController)
application.register("school-search", SchoolSearchController)
application.register("recent-schools", RecentSchoolsController)
application.register("chatbot", ChatbotController)
application.register("language-filter", LanguageFilterController)
application.register("language-selector", LanguageSelectorController)

export { application }
