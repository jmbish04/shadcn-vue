/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './components/**/*.{vue,js,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './app.vue',
    './plugins/**/*.{js,ts}',
    './registry/**/*.{vue,js,ts}',
    './lib/**/*.{js,ts}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
