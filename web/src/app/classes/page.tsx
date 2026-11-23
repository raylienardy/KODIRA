'use client'

import { useState, useEffect } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { Copy, Plus, Loader2 } from 'lucide-react'

interface ClassData {
  id: string
  name: string
  code: string
  description?: string
}

export default function ClassesPage() {
  const [classes, setClasses] = useState<ClassData[]>([])
  const [creating, setCreating] = useState(false)
  const [newClass, setNewClass] = useState({ name: '', description: '' })
  const supabase = createBrowserClient()

  const fetchClasses = async () => {
    const { data } = await supabase.from('classes').select('*').order('name')
    if (data) setClasses(data)
  }

  useEffect(() => {
    let active = true
    const load = async () => {
      const { data } = await supabase.from('classes').select('*').order('name')
      if (data && active) setClasses(data)
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    setCreating(true)
    
    const code = Math.random().toString(36).substring(2, 8).toUpperCase()
    
    await supabase.from('classes').insert({
      name: newClass.name,
      description: newClass.description,
      code: code
    })
    
    setNewClass({ name: '', description: '' })
    await fetchClasses()
    setCreating(false)
  }

  return (
    <AdminShell>
      <div className="space-y-8">
        <h1 className="text-2xl font-bold text-white">Manajemen Kelas</h1>
        
        <form onSubmit={handleCreate} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <h2 className="text-lg font-bold text-white mb-4">Buat Kelas Baru</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              type="text"
              placeholder="Nama Kelas"
              value={newClass.name}
              onChange={e => setNewClass({...newClass, name: e.target.value})}
              className="px-4 py-3 bg-slate-950 border border-slate-700 rounded-xl text-white"
              required
            />
            <input
              type="text"
              placeholder="Deskripsi"
              value={newClass.description}
              onChange={e => setNewClass({...newClass, description: e.target.value})}
              className="px-4 py-3 bg-slate-950 border border-slate-700 rounded-xl text-white"
            />
          </div>
          <button
            type="submit"
            disabled={creating}
            className="mt-4 flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-xl font-medium"
          >
            {creating ? <Loader2 className="animate-spin" /> : <Plus />}
            Buat Kelas
          </button>
        </form>
        
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-slate-500 uppercase tracking-wider text-xs">
              <tr>
                <th className="px-4 py-3">Nama</th>
                <th className="px-4 py-3">Kode</th>
                <th className="px-4 py-3">Deskripsi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {classes.map(cls => (
                <tr key={cls.id}>
                  <td className="px-4 py-4 font-medium text-white">{cls.name}</td>
                  <td className="px-4 py-4 font-mono text-blue-400 flex items-center gap-2">
                    {cls.code}
                    <button onClick={() => navigator.clipboard.writeText(cls.code)} className="text-slate-500 hover:text-white">
                      <Copy className="w-4 h-4" />
                    </button>
                  </td>
                  <td className="px-4 py-4 text-slate-400">{cls.description || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminShell>
  )
}
