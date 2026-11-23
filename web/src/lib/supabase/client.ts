import { createBrowserClient as createSupabaseBrowserClient } from "@supabase/ssr"

declare global {
  var __KODIRA_SUPABASE_CLIENT__:
    | ReturnType<typeof createSupabaseBrowserClient>
    | undefined
}

/**
 * Singleton browser client.
 *
 * Dipanggil dari komponen Client Component. Instance disimpan pada
 * `globalThis` supaya navigasi client-side, hot-reload dev, dan
 * multiple import di route berbeda selalu memakai client yang sama,
 * sehingga tidak ada peringatan "Multiple GoTrueClient instances"
 * maupun state yang bocor antar halaman.
 */
export const createBrowserClient = () => {
  if (typeof window === "undefined") {
    // Server-side: buat instance sementara yang tidak disimpan
    return createSupabaseBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-key",
      {
        cookies: {
          getAll() {
            return []
          },
          setAll() {
            return
          },
        },
      }
    )
  }

  const existing = globalThis.__KODIRA_SUPABASE_CLIENT__
  if (existing) return existing

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co"
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-key"

  globalThis.__KODIRA_SUPABASE_CLIENT__ = createSupabaseBrowserClient(url, key)
  return globalThis.__KODIRA_SUPABASE_CLIENT__
}
