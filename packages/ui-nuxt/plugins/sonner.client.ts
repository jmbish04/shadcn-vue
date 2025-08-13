import { Toaster } from 'vue-sonner'
import 'vue-sonner/style.css'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component('Toaster', Toaster)
})
