// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  modules: ['@nuxtjs/color-mode', '@nuxt/fonts'],
  vite: {
    ssr: {
      noExternal: ['vue-sonner']
    }
  },
  colorMode: {
    classSuffix: '',
  },
  build: {
    transpile: [
      'vee-validate',
      'vue-sonner',
    ],
  },
  nitro: {
    preset: 'cloudflare',
    minify: true,
  },
  routeRules: {
    '/**': { static: true },
  },
})
