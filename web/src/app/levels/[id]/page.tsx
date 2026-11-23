'use client'

import { useState, useEffect, Suspense } from 'react'
import { useParams } from 'next/navigation'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'

interface Level {
  id: number
  title: string
}

interface Material {
  id: number
  title?: string
  content?: string
  code_snippet?: string
}

interface Exercise {
  id: number
  type: string
  prompt: string
  payload?: unknown
}

// Wrapper component to use useParams inside Suspense
function LevelEditorContent() {
  const { id } = useParams()
  const [activeTab, setActiveTab] = useState('materi')
  const [level, setLevel] = useState<Level | null>(null)
  const [materials, setMaterials] = useState<Material[]>([])
  const [exercises, setExercises] = useState<Exercise[]>([])
  const supabase = createBrowserClient()

  useEffect(() => {
    let active = true
    const load = async () => {
      if (!id) return
      const { data: lvl } = await supabase.from('levels').select('*').eq('id', id).single()
      if (lvl && active) setLevel(lvl)
      const { data: mat } = await supabase.from('materials').select('*').eq('level_id', id).order('slide_order')
      if (mat && active) setMaterials(mat)
      const { data: ex } = await supabase.from('exercises').select('*').eq('level_id', id)
      if (ex && active) setExercises(ex)
    }
    const raf = requestAnimationFrame(() => load())
    return () => {
      active = false
      cancelAnimationFrame(raf)
    }
  }, [id, supabase])

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-white">Editor Level: {level?.title || 'Loading...'}</h1>
      
      <div className="flex gap-2 bg-slate-900 p-1 rounded-xl w-fit">
        <button onClick={() => setActiveTab('materi')} className={`px-4 py-2 rounded-lg ${activeTab === 'materi' ? 'bg-blue-600 text-white' : 'text-slate-400'}`}>Materi</button>
        <button onClick={() => setActiveTab('latihan')} className={`px-4 py-2 rounded-lg ${activeTab === 'latihan' ? 'bg-blue-600 text-white' : 'text-slate-400'}`}>Latihan</button>
        <button onClick={() => setActiveTab('kuis')} className={`px-4 py-2 rounded-lg ${activeTab === 'kuis' ? 'bg-blue-600 text-white' : 'text-slate-400'}`}>Kuis</button>
      </div>

      {activeTab === 'materi' && (
        <div className="space-y-4">
          {materials.map(m => (
            <div key={m.id} className="bg-slate-900 p-4 rounded-xl">
              <h3 className="text-white font-medium">{m.title}</h3>
              <p className="text-slate-400 mt-1">{m.content}</p>
              <pre className="bg-[#1E1E1E] p-3 rounded-lg mt-2 font-mono text-xs text-green-400">{m.code_snippet}</pre>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'latihan' && (
        <div className="space-y-4">
          {exercises.filter(e => e.type === 'drag_drop' || e.type === 'fill_in_the_blank').map(e => (
            <div key={e.id} className="bg-slate-900 p-4 rounded-xl text-slate-300">{e.prompt}</div>
          ))}
        </div>
      )}

      {activeTab === 'kuis' && (
        <div className="space-y-4">
          <button className="px-4 py-2 bg-purple-600 text-white rounded-xl">Generate Soal AI</button>
          {exercises.filter(e => e.type === 'multiple_choice').map(e => (
            <div key={e.id} className="bg-slate-900 p-4 rounded-xl text-slate-300">{e.prompt}</div>
          ))}
        </div>
      )}
    </div>
  )
}

export default function LevelEditorPage() {
  return (
    <AdminShell>
      <Suspense fallback={<div className="text-white">Loading Editor...</div>}>
        <LevelEditorContent />
      </Suspense>
    </AdminShell>
  )
}
