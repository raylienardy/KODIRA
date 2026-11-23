'use client'

import { useState, useEffect } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { Copy, Plus, Loader2, Trash2, CheckCircle, AlertCircle } from 'lucide-react'

interface ClassData {
  id: string
  name: string
  code: string
  description?: string
  created_at?: string
}

export default function ClassesPage() {
  const [classes, setClasses] = useState<ClassData[]>([])
  const [creating, setCreating] = useState(false)
  const [newClass, setNewClass] = useState({ name: '', description: '' })
  const [notification, setNotification] = useState<{ type: 'success' | 'error'; message: string } | null>(null)
  const supabase = createBrowserClient()

  const CHARSET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

  const generateCode = (): string => {
    let code = ''
    for (let i = 0; i < 6; i++) {
      code += CHARSET.charAt(Math.floor(Math.random() * CHARSET.length))
    }
    return code
  }

interface ClassTeacherRow {
  teacher_id: string
  classes: {
    id: string
    name: string
    code: string
    description?: string
    created_at?: string
  } | null
}

const fetchClasses = async () => {
  const { data } = await supabase
    .from('class_teachers')
    .select(`
      teacher_id,
      classes:class_id (
        id,
        name,
        code,
        description,
        created_at
      )
    `)
  if (data && data.length > 0) {
    const typedData = data as unknown as ClassTeacherRow[]
    const mapped = typedData
      .map((item) => item.classes)
      .filter((c): c is NonNullable<ClassTeacherRow['classes']> => !!c)
      .map((c) => ({
        id: c.id,
        name: c.name,
        code: c.code,
        description: c.description,
        created_at: c.created_at
      }))
    setClasses(mapped)
  } else {
    setClasses([])
  }
}

  useEffect(() => {
    let active = true
    const load = async () => {
      const { data } = await supabase
        .from('class_teachers')
        .select(`
          teacher_id,
          classes:class_id (
            id,
            name,
            code,
            description,
            created_at
          )
        `)
      if (data && active && data.length > 0) {
        const typedData = data as unknown as ClassTeacherRow[]
        const mapped = typedData
          .map((item) => item.classes)
          .filter((c): c is NonNullable<ClassTeacherRow['classes']> => !!c)
          .map((c) => ({
            id: c.id,
            name: c.name,
            code: c.code,
            description: c.description,
            created_at: c.created_at
          }))
        setClasses(mapped)
      } else if (active) {
        setClasses([])
      }
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  const dismissNotification = () => setNotification(null)

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    setCreating(true)
    setNotification(null)

    const name = newClass.name.trim()
    const desc = newClass.description.trim() || null

    if (!name) {
      setNotification({ type: 'error', message: 'Nama kelas wajib diisi.' })
      setCreating(false)
      return
    }

    // 1. Ambil user yang sedang login
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      setNotification({ type: 'error', message: 'Anda belum login. Silakan masuk terlebih dahulu.' })
      setCreating(false)
      return
    }

    // 2. Generate kode kelas 6 karakter (tanpa ambigu O/0/I/1)
    const code = generateCode()

    // 3. Coba RPC create_class terlebih dahulu
    const { data: rpcData, error: rpcError } = await supabase.rpc('create_class', {
      p_name: name,
      p_description: desc
    })

    if (!rpcError && rpcData && rpcData.success) {
      // RPC berhasil — tampilkan notifikasi dengan kode yang di-generate oleh DB
      setNotification({ type: 'success', message: `Kelas "${name}" berhasil dibuat. Kode gabung: ${rpcData.code}` })
      setNewClass({ name: '', description: '' })
      await fetchClasses()
      setCreating(false)
      return
    }

    // 4. Fallback: dua langkah — insert classes, lalu insert class_teachers
    const { data: newClassRow, error: insertErr } = await supabase
      .from('classes')
      .insert({
        name: name,
        description: desc,
        code: code,
        created_by: user.id
      })
      .select()
      .single()

    if (insertErr || !newClassRow) {
      setNotification({ type: 'error', message: insertErr?.message || 'Gagal menyimpan kelas baru.' })
      setCreating(false)
      return
    }

    const { error: ctErr } = await supabase
      .from('class_teachers')
      .insert({
        class_id: newClassRow.id,
        teacher_id: user.id,
        role: 'owner'
      })

    if (ctErr) {
      setNotification({ type: 'error', message: `Kelas tersimpan namun gagal mengaitkan pengajar: ${ctErr.message}` })
      setCreating(false)
      return
    }

    setNotification({ type: 'success', message: `Kelas "${name}" berhasil dibuat. Kode gabung: ${code}` })
    setNewClass({ name: '', description: '' })
    await fetchClasses()
    setCreating(false)
  }

  const handleDelete = async (cls: ClassData) => {
    if (!cls || !cls.id) return
    if (!confirm(`Yakin ingin menghapus kelas "${cls.name}" (${cls.code})? Data siswa dalam kelas ini akan ikut terhapus.`)) {
      return
    }
    const { error } = await supabase.from('classes').delete().eq('id', cls.id)
    if (error) {
      setNotification({ type: 'error', message: `Gagal menghapus kelas: ${error.message}` })
      return
    }
    setNotification({ type: 'success', message: `Kelas "${cls.name}" berhasil dihapus.` })
    await fetchClasses()
  }

  const handleCopyCode = async (code: string) => {
    try {
      await navigator.clipboard.writeText(code)
      const originalNotification = notification
      setNotification({ type: 'success', message: `"${code}" Tersalin!` })
      setTimeout(() => {
        setNotification(originalNotification ?? null)
      }, 1500)
    } catch {
      setNotification({ type: 'error', message: 'Gagal menyalin kode kelas.' })
    }
  }

  return (
    <AdminShell>
      <div className="space-y-8">
        <h1 className="text-2xl font-bold text-white">Manajemen Kelas</h1>

        {/* Notifikasi */}
        {notification && (
          <div
            className={`p-4 rounded-xl border flex items-center gap-3 ${
              notification.type === 'success'
                ? 'bg-green-900/20 border-green-500/30 text-green-300'
                : 'bg-red-900/20 border-red-500/30 text-red-300'
            }`}
          >
            {notification.type === 'success' ? <CheckCircle className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
            <span className="text-sm">{notification.message}</span>
            <button onClick={dismissNotification} className="ml-auto p-1 hover:opacity-70">
              <span className="sr-only">Tutup</span>
              <svg className="w-4 h-4 currentColor" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        )}

        {/* Form Buat Kelas */}
        <form onSubmit={handleCreate} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <h2 className="text-lg font-bold text-white mb-4">Buat Kelas Baru</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              type="text"
              placeholder="Nama Kelas (contoh: PBO A)"
              value={newClass.name}
              onChange={e => setNewClass({ ...newClass, name: e.target.value })}
              className="px-4 py-3 bg-slate-950 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
              required
            />
            <input
              type="text"
              placeholder="Deskripsi (opsional)"
              value={newClass.description}
              onChange={e => setNewClass({ ...newClass, description: e.target.value })}
              className="px-4 py-3 bg-slate-950 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
            />
          </div>
          <button
            type="submit"
            disabled={creating}
            className="mt-4 flex items-center justify-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
          >
            {creating ? <Loader2 className="animate-spin" /> : <Plus />}
            Buat Kelas
          </button>
        </form>

        {/* Tabel Daftar Kelas */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-slate-500 uppercase tracking-wider text-xs border-b border-slate-800">
              <tr>
                <th className="px-4 py-3">Nama</th>
                <th className="px-4 py-3">Kode</th>
                <th className="px-4 py-3">Deskripsi</th>
                <th className="px-4 py-3 text-center">AKSI</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {classes.length > 0 ? classes.map(cls => (
                <tr key={cls.id} className="hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 py-4 font-medium text-white">{cls.name}</td>
                  <td className="px-4 py-4 font-mono text-blue-400">{cls.code}</td>
                  <td className="px-4 py-4 text-slate-400">{cls.description || '-'}</td>
                  <td className="px-4 py-4 text-center flex justify-center gap-2">
                    <button
                      onClick={() => handleCopyCode(cls.code)}
                      className="p-2 bg-blue-900/50 text-blue-400 hover:bg-blue-500 hover:text-white rounded-lg transition-colors border border-blue-500/20"
                      title="Salin kode gabung"
                    >
                      <Copy className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(cls)}
                      className="p-2 bg-red-900/20 text-red-400 hover:bg-red-600 hover:text-white rounded-lg transition-colors border border-red-500/20"
                      title="Hapus kelas"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              )) : (
                <tr>
                  <td colSpan={4} className="px-4 py-12 text-center text-slate-500 italic">
                    Belum ada kelas. Buat kelas pertama Anda di formulir di atas.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </AdminShell>
  )
}
