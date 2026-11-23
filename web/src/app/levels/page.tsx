'use client'

import { useState, useEffect } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import Link from 'next/link'
import { Trash2, Edit } from 'lucide-react'

interface Level {
  id: number
  level_number: number
  title: string
  description?: string
  difficulty?: number
}

export default function LevelsPage() {
  const [levels, setLevels] = useState<Level[]>([])
  const supabase = createBrowserClient()

  useEffect(() => {
    let active = true
    const load = async () => {
      const { data } = await supabase.from('levels').select('*').order('level_number')
      if (data && active) setLevels(data)
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  const tiers = [
    { name: 'Mudah', min: 0, max: 15 },
    { name: 'Sedang', min: 16, max: 35 },
    { name: 'Tinggi', min: 36, max: Infinity }
  ]

  return (
    <AdminShell>
      <div className="space-y-8">
        <h1 className="text-2xl font-bold text-white">Manajemen Level</h1>
        
        {tiers.map(tier => (
          <div key={tier.name} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
            <h2 className="text-xl font-bold text-white mb-4">{tier.name}</h2>
            <div className="grid gap-4">
              {levels.filter(l => l.level_number >= tier.min && l.level_number <= tier.max).map(l => (
                <div key={l.id} className="flex justify-between items-center p-4 bg-slate-950 rounded-xl">
                  <span className="text-slate-300">{l.level_number}. {l.title}</span>
                  <div className="flex gap-2">
                    <Link href={`/levels/${l.id}`} className="p-2 text-blue-400 hover:bg-blue-950 rounded-lg"><Edit className="w-5 h-5"/></Link>
                    <button className="p-2 text-red-400 hover:bg-red-950 rounded-lg"><Trash2 className="w-5 h-5"/></button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </AdminShell>
  )
}
