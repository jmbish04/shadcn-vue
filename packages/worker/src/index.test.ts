import app from './index'
import { describe, it, expect } from 'vitest'

const env = {
  ASSETS: {
    fetch: async (req: Request) => {
      const url = new URL(req.url)
      if (url.pathname === '/index.html') {
        return new Response('<html></html>', { headers: { 'content-type': 'text/html' } })
      }
      return new Response('not found', { status: 404 })
    }
  }
}

describe('worker', () => {
  it('health check', async () => {
    const res = await app.fetch(new Request('http://localhost/health'), env)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ ok: true })
  })

  it('serves ui with fallback', async () => {
    const res = await app.fetch(new Request('http://localhost/admin/xyz'), env)
    expect(res.status).toBe(200)
    expect(res.headers.get('content-type')).toContain('text/html')
  })
})
