import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  modules: ['@nuxtjs/color-mode', '@nuxt/fonts'],
  vite: {
    plugins: [tailwindcss()],
  },
  colorMode: { classSuffix: '' },
  build: {
    transpile: ['vee-validate', 'vue-sonner'],
  },
  nitro: { preset: 'node' },
  app: { baseURL: '/' },
})
