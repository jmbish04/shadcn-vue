import { Hono } from 'hono'

type Env = { ASSETS: Fetcher }

const app = new Hono<{ Bindings: Env }>()

app.get('/health', c => c.json({ ok: true }))

app.get('/admin/*', async (c) => {
  const url = new URL(c.req.url)
  const path = url.pathname.replace(/^\/admin/, '') || '/index.html'
  const res = await c.env.ASSETS.fetch(new Request(new URL(path, 'http://assets')))
  if (res.ok) return res
  const fallback = await c.env.ASSETS.fetch(new Request(new URL('/index.html', 'http://assets')))
  return new Response(await fallback.arrayBuffer(), {
    status: 200,
    headers: { 'content-type': 'text/html; charset=utf-8' }
  })
})

app.get('/', (c) => c.redirect('/admin/', 302))

export default app
