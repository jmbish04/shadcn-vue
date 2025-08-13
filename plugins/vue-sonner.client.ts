// Client-only plugin to load vue-sonner styles
// This ensures the CSS is only loaded on the client side, not during SSR
import 'vue-sonner/style.css'

export default defineNuxtPlugin(() => {
  // Plugin initialization (client-side only)
})
