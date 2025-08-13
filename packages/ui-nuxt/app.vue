<script setup lang="ts">
const activeTheme = useCookie<string>('active_theme', { readonly: true })
const isScaled = computed(() => !!activeTheme.value?.endsWith('-scaled'))
const colorMode = useColorMode()
</script>

<template>
  <Body
    class="bg-background overscroll-none font-sans antialiased"
    :class="[
      activeTheme ? `theme-${activeTheme}` : '',
      isScaled ? 'theme-scaled' : '',
    ]"
  >
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>

    <ClientOnly><Toaster :theme="colorMode.preference as any || 'system'" /></ClientOnly>
  </Body>
</template>
