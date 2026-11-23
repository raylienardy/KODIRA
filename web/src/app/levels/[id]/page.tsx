'use client'

import { useState, useEffect, useCallback } from 'react'
import { useParams } from 'next/navigation'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { BookOpen, Code, FileText, Save, Trash2, Wand2, Eye, X, Pencil } from 'lucide-react'

interface Level {
  id: number
  title: string
  topic?: string | null
  description?: string | null
  level_number?: number
}

interface Material {
  id: number
  slide_order: number
  title: string
  content: string
  code_snippet?: string | null
}

interface Exercise {
  id: number
  type: string
  prompt: string
  payload: Record<string, unknown>
  difficulty: number | null
  alternative_answers: string[]
}

interface MaterialChunk {
  id: string
  chunk_order: number
  topic_title: string | null
  source_title: string | null
  content_text: string
  keywords: string[] | null
  created_at: string
}

interface EditingMaterial {
  id: number | null
  slide_order: string
  title: string
  content: string
  code_snippet: string
}

interface EditingExercise {
  id: number | null
  type: 'drag_drop' | 'fill_in_the_blank' | 'multiple_choice'
  prompt: string
  payload_text: string
  difficulty: string
  alternative_answers_text: string
}

const EMPTY_MATERIAL: EditingMaterial = {
  id: null,
  slide_order: '',
  title: '',
  content: '',
  code_snippet: '',
}

const EMPTY_EXERCISE: EditingExercise = {
  id: null,
  type: 'drag_drop',
  prompt: '',
  payload_text: '{\n  "tokens": [\n    { "id": "t1", "text": "int" },\n    { "id": "t2", "text": "x" }\n  ],\n  "answer": ["t1", "t2"]\n}',
  difficulty: '1',
  alternative_answers_text: '',
}

const EMPTY_QUIZ: EditingExercise = {
  id: null,
  type: 'multiple_choice',
  prompt: '',
  payload_text: '{\n  "options": [\n    "Opsi A",\n    "Opsi B",\n    "Opsi C",\n    "Opsi D"\n  ],\n  "answer": 0,\n  "explanation": "Penjelasan jawaban benar."\n}',
  difficulty: '1',
  alternative_answers_text: '',
}

export default function LevelEditorPage() {
  const params = useParams<{ id: string }>()
  const levelId = Number(params.id)
  const supabase = createBrowserClient()

  const [level, setLevel] = useState<Level | null>(null)
  const [materials, setMaterials] = useState<Material[]>([])
  const [exercises, setExercises] = useState<Exercise[]>([])
  const [chunks, setChunks] = useState<MaterialChunk[]>([])
  const [activeTab, setActiveTab] = useState<'materi' | 'latihan' | 'kuis' | 'chunk'>('materi')
  const [notification, setNotification] = useState<{ type: 'success' | 'error'; message: string } | null>(null)
  const [busy, setBusy] = useState(false)
  const [viewChunk, setViewChunk] = useState<MaterialChunk | null>(null)

  const [editingMaterial, setEditingMaterial] = useState<EditingMaterial>(EMPTY_MATERIAL)
  const [editingExercise, setEditingExercise] = useState<EditingExercise>(EMPTY_EXERCISE)
  const [editingQuiz, setEditingQuiz] = useState<EditingExercise>(EMPTY_QUIZ)

  const showNotification = (type: 'success' | 'error', message: string) => {
    setNotification({ type, message })
    setTimeout(() => setNotification(null), 5000)
  }

  const loadData = useCallback(async () => {
    if (!levelId || Number.isNaN(levelId)) return
    const [levelRes, materialRes, exerciseRes, chunkRes] = await Promise.all([
      supabase.from('levels').select('id, title, topic, description, level_number').eq('id', levelId).single(),
      supabase.from('materials').select('id, slide_order, title, content, code_snippet').eq('level_id', levelId).order('slide_order', { ascending: true }),
      supabase.from('exercises').select('id, type, prompt, payload, difficulty, alternative_answers').eq('level_id', levelId).order('id', { ascending: true }),
      supabase.from('class_material_chunks').select('id, chunk_order, topic_title, source_title, content_text, keywords, created_at').eq('level_id', levelId).order('chunk_order', { ascending: true }),
    ])
    if (levelRes.data) setLevel(levelRes.data as Level)
    if (materialRes.data) setMaterials(materialRes.data as Material[])
    if (exerciseRes.data) {
      setExercises((exerciseRes.data as Array<Record<string, unknown>>).map((raw) => ({
        id: raw.id as number,
        type: String(raw.type ?? ''),
        prompt: String(raw.prompt ?? ''),
        payload: (raw.payload && typeof raw.payload === 'object' ? raw.payload : {}) as Record<string, unknown>,
        difficulty: typeof raw.difficulty === 'number' ? raw.difficulty : null,
        alternative_answers: Array.isArray(raw.alternative_answers)
          ? (raw.alternative_answers as unknown[]).map((v) => String(v))
          : [],
      })))
    }
    if (chunkRes.data) setChunks(chunkRes.data as MaterialChunk[])
  }, [levelId, supabase])

  useEffect(() => {
    let active = true
    const load = async () => {
      if (!levelId || Number.isNaN(levelId)) return
      const [levelRes, materialRes, exerciseRes, chunkRes] = await Promise.all([
        supabase.from('levels').select('id, title, topic, description, level_number').eq('id', levelId).single(),
        supabase.from('materials').select('id, slide_order, title, content, code_snippet').eq('level_id', levelId).order('slide_order', { ascending: true }),
        supabase.from('exercises').select('id, type, prompt, payload, difficulty, alternative_answers').eq('level_id', levelId).order('id', { ascending: true }),
        supabase.from('class_material_chunks').select('id, chunk_order, topic_title, source_title, content_text, keywords, created_at').eq('level_id', levelId).order('chunk_order', { ascending: true }),
      ])
      if (!active) return
      if (levelRes.data) setLevel(levelRes.data as Level)
      if (materialRes.data) setMaterials(materialRes.data as Material[])
      if (exerciseRes.data) {
        setExercises((exerciseRes.data as Array<Record<string, unknown>>).map((raw) => ({
          id: raw.id as number,
          type: String(raw.type ?? ''),
          prompt: String(raw.prompt ?? ''),
          payload: (raw.payload && typeof raw.payload === 'object' ? raw.payload : {}) as Record<string, unknown>,
          difficulty: typeof raw.difficulty === 'number' ? raw.difficulty : null,
          alternative_answers: Array.isArray(raw.alternative_answers)
            ? (raw.alternative_answers as unknown[]).map((v) => String(v))
            : [],
        })))
      }
      if (chunkRes.data) setChunks(chunkRes.data as MaterialChunk[])
    }
    load()
    return () => {
      active = false
    }
  }, [levelId, supabase])

  const parseJson = (text: string, label: string): Record<string, unknown> => {
    try {
      const parsed: unknown = JSON.parse(text)
      if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new Error('Harus berupa objek JSON.')
      }
      return parsed as Record<string, unknown>
    } catch (err) {
      throw new Error(`${label} bukan JSON valid: ${err instanceof Error ? err.message : String(err)}`)
    }
  }

  const saveMaterial = async (e: React.FormEvent) => {
    e.preventDefault()
    setBusy(true)
    try {
      const slideOrder = parseInt(editingMaterial.slide_order, 10)
      if (Number.isNaN(slideOrder) || slideOrder < 1) throw new Error('Urutan slide harus positif.')
      const payload = {
        level_id: levelId,
        slide_order: slideOrder,
        title: editingMaterial.title,
        content: editingMaterial.content,
        code_snippet: editingMaterial.code_snippet || null,
      }
      const { error } = editingMaterial.id
        ? await supabase.from('materials').update(payload).eq('id', editingMaterial.id)
        : await supabase.from('materials').insert(payload)
      if (error) throw error
      setEditingMaterial(EMPTY_MATERIAL)
      showNotification('success', editingMaterial.id ? 'Slide diperbarui.' : 'Slide ditambahkan.')
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menyimpan slide.')
    } finally {
      setBusy(false)
    }
  }

  const deleteMaterial = async (id: number) => {
    if (!confirm('Hapus slide materi ini?')) return
    setBusy(true)
    try {
      const { error } = await supabase.from('materials').delete().eq('id', id)
      if (error) throw error
      showNotification('success', 'Slide dihapus.')
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menghapus slide.')
    } finally {
      setBusy(false)
    }
  }

  const saveExercise = async (e: React.FormEvent, kind: 'latihan' | 'kuis') => {
    e.preventDefault()
    const draft = kind === 'latihan' ? editingExercise : editingQuiz
    setBusy(true)
    try {
      const payload = parseJson(draft.payload_text, 'Payload')
      const alternatives = draft.alternative_answers_text
        .split('\n')
        .map((line) => line.trim())
        .filter(Boolean)
      const row = {
        level_id: levelId,
        type: draft.type,
        prompt: draft.prompt,
        payload,
        difficulty: parseInt(draft.difficulty, 10) || 1,
        alternative_answers: alternatives,
      }
      const { error } = draft.id
        ? await supabase.from('exercises').update(row).eq('id', draft.id)
        : await supabase.from('exercises').insert(row)
      if (error) throw error
      if (kind === 'latihan') setEditingExercise(EMPTY_EXERCISE)
      else setEditingQuiz(EMPTY_QUIZ)
      showNotification('success', draft.id ? 'Soal diperbarui.' : 'Soal ditambahkan.')
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menyimpan soal.')
    } finally {
      setBusy(false)
    }
  }

  const editExercise = (exercise: Exercise) => {
    const draft: EditingExercise = {
      id: exercise.id,
      type: exercise.type === 'fill_in_the_blank' || exercise.type === 'multiple_choice'
        ? exercise.type
        : 'drag_drop',
      prompt: exercise.prompt,
      payload_text: JSON.stringify(exercise.payload, null, 2),
      difficulty: String(exercise.difficulty || 1),
      alternative_answers_text: (exercise.alternative_answers || []).join('\n'),
    }
    if (exercise.type === 'multiple_choice') setEditingQuiz(draft)
    else setEditingExercise(draft)
    setActiveTab(exercise.type === 'multiple_choice' ? 'kuis' : 'latihan')
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  const deleteExercise = async (id: number) => {
    if (!confirm('Hapus soal ini?')) return
    setBusy(true)
    try {
      const { error } = await supabase.from('exercises').delete().eq('id', id)
      if (error) throw error
      showNotification('success', 'Soal dihapus.')
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menghapus soal.')
    } finally {
      setBusy(false)
    }
  }

  const deleteChunk = async (id: string) => {
    if (!confirm('Hapus potongan materi PDF ini? Tindakan ini tidak dapat dibatalkan.')) return
    setBusy(true)
    try {
      const { error } = await supabase.from('class_material_chunks').delete().eq('id', id)
      if (error) throw error
      setViewChunk(null)
      showNotification('success', 'Chunk dihapus.')
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menghapus chunk.')
    } finally {
      setBusy(false)
    }
  }

  const generateQuizWithAi = async () => {
    if (!level) return
    setBusy(true)
    try {
      const { data, error } = await supabase.functions.invoke('ai-generate-quiz', {
        body: {
          levelId: levelId,
          level_id: levelId,
          topic: level.title,
          count: 3,
          questionCount: 3,
          mode: 'quiz',
          session_nonce: Date.now(),
        },
      })
      if (error) throw error
      const questions = Array.isArray(data?.questions) ? data.questions : []
      if (questions.length === 0) throw new Error('AI tidak menghasilkan soal.')
      const rows = questions.map((q: { question: string; options: string[]; answer: number; explanation: string }) => ({
        level_id: levelId,
        type: 'multiple_choice',
        prompt: q.question,
        payload: { options: q.options, answer: q.answer, explanation: q.explanation },
        difficulty: 1,
        alternative_answers: [],
      }))
      const { error: insertError } = await supabase.from('exercises').insert(rows)
      if (insertError) throw insertError
      showNotification('success', `${rows.length} soal kuis berhasil dibuat oleh AI.`)
      await loadData()
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal membuat kuis dengan AI.')
    } finally {
      setBusy(false)
    }
  }

  const latihan = exercises.filter(e => e.type === 'drag_drop' || e.type === 'fill_in_the_blank')
  const kuis = exercises.filter(e => e.type === 'multiple_choice' || e.type === 'quiz')

  return (
    <AdminShell>
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <h1 className="text-2xl font-bold text-white">Editor Level: {level?.title || 'Loading...'}</h1>
            {level?.topic && <p className="text-slate-400 text-sm mt-1">Topik: {level.topic}</p>}
          </div>
          <span className="text-xs font-semibold px-3 py-1.5 rounded-lg bg-blue-600/20 text-blue-400 border border-blue-500/30">
            ID: {levelId}
          </span>
        </div>

        {notification && (
          <div className={`px-4 py-3 rounded-xl text-sm ${
            notification.type === 'success'
              ? 'bg-emerald-500/15 border border-emerald-500/30 text-emerald-300'
              : 'bg-red-500/15 border border-red-500/30 text-red-300'
          }`}>
            {notification.message}
          </div>
        )}

        {/* Tabs */}
        <div className="flex flex-wrap gap-2 bg-slate-900 p-1.5 rounded-xl w-fit border border-slate-800">
          <button onClick={() => setActiveTab('materi')} className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium ${activeTab === 'materi' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}>
            <BookOpen className="w-4 h-4" /> Materi ({materials.length})
          </button>
          <button onClick={() => setActiveTab('latihan')} className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium ${activeTab === 'latihan' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}>
            <Code className="w-4 h-4" /> Latihan ({latihan.length})
          </button>
          <button onClick={() => setActiveTab('kuis')} className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium ${activeTab === 'kuis' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}>
            <Wand2 className="w-4 h-4" /> Kuis ({kuis.length})
          </button>
          <button onClick={() => setActiveTab('chunk')} className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-medium ${activeTab === 'chunk' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}>
            <FileText className="w-4 h-4" /> Chunk PDF ({chunks.length})
          </button>
        </div>

        {/* Materi Tab */}
        {activeTab === 'materi' && (
          <div className="space-y-6">
            <form onSubmit={saveMaterial} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl">
              <h3 className="text-white font-semibold mb-4">
                {editingMaterial.id ? 'Edit Slide Materi' : 'Tambah Slide Materi'}
              </h3>
              <div className="grid grid-cols-1 gap-3">
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Urutan Slide</label>
                  <input
                    type="number"
                    min={1}
                    placeholder="1"
                    value={editingMaterial.slide_order}
                    onChange={e => setEditingMaterial({ ...editingMaterial, slide_order: e.target.value })}
                    className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                    required
                  />
                </div>
                <input
                  type="text"
                  placeholder="Judul slide"
                  value={editingMaterial.title}
                  onChange={e => setEditingMaterial({ ...editingMaterial, title: e.target.value })}
                  className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                  required
                />
                <textarea
                  placeholder="Isi materi / penjelasan konsep"
                  rows={4}
                  value={editingMaterial.content}
                  onChange={e => setEditingMaterial({ ...editingMaterial, content: e.target.value })}
                  className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white resize-none"
                />
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Code Snippet (Opsional)</label>
                  <textarea
                    placeholder="int x = 5;"
                    rows={4}
                    value={editingMaterial.code_snippet}
                    onChange={e => setEditingMaterial({ ...editingMaterial, code_snippet: e.target.value })}
                    className="px-4 py-2.5 font-mono text-xs bg-[#1E1E1E] border border-slate-700 rounded-xl text-green-400 resize-none"
                  />
                </div>
                <div className="flex gap-2">
                  <button type="submit" disabled={busy} className="flex items-center justify-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-xl font-medium disabled:opacity-50">
                    <Save className="w-4 h-4" /> {editingMaterial.id ? 'Simpan Perubahan' : 'Tambah Slide'}
                  </button>
                  {editingMaterial.id && (
                    <button type="button" onClick={() => setEditingMaterial(EMPTY_MATERIAL)} className="px-5 py-2.5 bg-slate-800 text-slate-300 rounded-xl font-medium">
                      Batal
                    </button>
                  )}
                </div>
              </div>
            </form>

            <div className="space-y-4">
              {materials.map(m => (
                <div key={m.id} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl flex justify-between items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="text-white font-medium">{m.title}</h4>
                      <span className="text-xs text-slate-500 font-mono">Slide #{m.slide_order}</span>
                    </div>
                    <p className="text-slate-400 text-sm whitespace-pre-wrap">{m.content}</p>
                    {m.code_snippet && (
                      <pre className="bg-[#1E1E1E] p-3.5 rounded-lg mt-3 font-mono text-xs text-green-400 overflow-x-auto">
                        {m.code_snippet}
                      </pre>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => setEditingMaterial({ id: m.id, slide_order: String(m.slide_order), title: m.title, content: m.content, code_snippet: m.code_snippet || '' })} className="p-2.5 bg-slate-800 hover:bg-blue-600 text-blue-400 hover:text-white rounded-xl transition-colors">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button onClick={() => deleteMaterial(m.id)} className="p-2.5 bg-slate-800 hover:bg-red-600 text-red-400 hover:text-white rounded-xl transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
              {materials.length === 0 && (
                <div className="text-center py-8 text-slate-500 italic">Belum ada slide materi.</div>
              )}
            </div>
          </div>
        )}

        {/* Latihan Tab */}
        {activeTab === 'latihan' && (
          <div className="space-y-6">
            <form onSubmit={(e) => saveExercise(e, 'latihan')} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl">
              <h3 className="text-white font-semibold mb-4">
                {editingExercise.id ? 'Edit Soal Latihan' : 'Tambah Soal Latihan'}
              </h3>
              <div className="grid grid-cols-1 gap-3">
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Jenis Soal</label>
                  <select
                    value={editingExercise.type}
                    onChange={e => setEditingExercise({ ...editingExercise, type: e.target.value as 'drag_drop' | 'fill_in_the_blank' | 'multiple_choice' })}
                    className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                  >
                    <option value="drag_drop">Drag & Drop</option>
                    <option value="fill_in_the_blank">Fill in the Blank</option>
                  </select>
                </div>
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Pertanyaan / Prompt</label>
                  <textarea
                    rows={2}
                    placeholder="Susun kode deklarasi variabel integer berikut..."
                    value={editingExercise.prompt}
                    onChange={e => setEditingExercise({ ...editingExercise, prompt: e.target.value })}
                    className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white resize-none"
                    required
                  />
                </div>
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Payload JSON — token & jawaban (editor ramah pengguna)</label>
                  <textarea
                    rows={6}
                    value={editingExercise.payload_text}
                    onChange={e => setEditingExercise({ ...editingExercise, payload_text: e.target.value })}
                    className="w-full px-4 py-2.5 font-mono text-xs bg-[#1E1E1E] border border-slate-700 rounded-xl text-blue-300 resize-none"
                  />
                  <p className="text-slate-500 text-xs mt-1">
                    Drag &amp; drop: {'{ "tokens": [{ "id": "t1", "text": "int" }], "answer": ["t1"] }'} · Fill in the blank: {'{ "template": "___ x = 5;", "answer": "int" }'}
                  </p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="text-xs text-slate-500 block mb-1">Difficulty (1–3)</label>
                    <select
                      value={editingExercise.difficulty}
                      onChange={e => setEditingExercise({ ...editingExercise, difficulty: e.target.value })}
                      className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                    >
                      <option value="1">1 — Mudah</option>
                      <option value="2">2 — Sedang</option>
                      <option value="3">3 — Tinggi</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-xs text-slate-500 block mb-1">Jawaban Alternatif Setara (satu per baris)</label>
                    <textarea
                      rows={3}
                      placeholder={'int x = 5;\nint y = 5;'}
                      value={editingExercise.alternative_answers_text}
                      onChange={e => setEditingExercise({ ...editingExercise, alternative_answers_text: e.target.value })}
                      className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white resize-none"
                    />
                  </div>
                </div>
                <div className="flex gap-2">
                  <button type="submit" disabled={busy} className="flex items-center justify-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-xl font-medium disabled:opacity-50">
                    <Save className="w-4 h-4" /> {editingExercise.id ? 'Simpan Perubahan' : 'Tambah Latihan'}
                  </button>
                  {editingExercise.id && (
                    <button type="button" onClick={() => setEditingExercise(EMPTY_EXERCISE)} className="px-5 py-2.5 bg-slate-800 text-slate-300 rounded-xl font-medium">
                      Batal
                    </button>
                  )}
                </div>
              </div>
            </form>

            <div className="space-y-4">
              {latihan.map(e => (
                <div key={e.id} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl flex justify-between items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-xs font-mono bg-cyan-950 text-cyan-400 px-2 py-0.5 rounded-md">{e.type}</span>
                      <span className="text-xs text-slate-500">Difficulty {e.difficulty || 1}</span>
                    </div>
                    <p className="text-white">{e.prompt}</p>
                    <pre className="mt-2 text-xs text-slate-500 font-mono bg-slate-950 p-2 rounded-lg overflow-x-auto">{JSON.stringify(e.payload, null, 2)}</pre>
                    {e.alternative_answers.length > 0 && (
                      <div className="mt-2">
                        <p className="text-xs text-emerald-400 font-semibold">Jawaban alternatif setara:</p>
                        <ul className="list-disc list-inside text-xs text-slate-400">
                          {e.alternative_answers.map((a, i) => <li key={i}>{a}</li>)}
                        </ul>
                      </div>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => editExercise(e)} className="p-2.5 bg-slate-800 hover:bg-blue-600 text-blue-400 hover:text-white rounded-xl transition-colors">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button onClick={() => deleteExercise(e.id)} className="p-2.5 bg-slate-800 hover:bg-red-600 text-red-400 hover:text-white rounded-xl transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
              {latihan.length === 0 && (
                <div className="text-center py-8 text-slate-500 italic">Belum ada soal latihan.</div>
              )}
            </div>
          </div>
        )}

        {/* Kuis Tab */}
        {activeTab === 'kuis' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <span className="text-slate-400 text-sm">Generate 3 soal pilihan ganda otomatis menggunakan AI</span>
              <button onClick={generateQuizWithAi} disabled={busy} className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-xl font-medium shadow-lg disabled:opacity-50">
                <Wand2 className="w-5 h-5" /> Generate Soal AI
              </button>
            </div>

            <form onSubmit={(e) => saveExercise(e, 'kuis')} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl">
              <h3 className="text-white font-semibold mb-4">
                {editingQuiz.id ? 'Edit Soal Kuis' : 'Tambah Soal Pilihan Ganda Manual'}
              </h3>
              <div className="grid grid-cols-1 gap-3">
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Pertanyaan Kuis</label>
                  <input
                    type="text"
                    placeholder="Apa fungsi dari keyword 'static' pada Java?"
                    value={editingQuiz.prompt}
                    onChange={e => setEditingQuiz({ ...editingQuiz, prompt: e.target.value })}
                    className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                    required
                  />
                </div>
                <div>
                  <label className="text-xs text-slate-500 block mb-1">Payload JSON — 4 opsi, indeks jawaban, penjelasan</label>
                  <textarea
                    rows={8}
                    value={editingQuiz.payload_text}
                    onChange={e => setEditingQuiz({ ...editingQuiz, payload_text: e.target.value })}
                    className="w-full px-4 py-2.5 font-mono text-xs bg-[#1E1E1E] border border-slate-700 rounded-xl text-blue-300 resize-none"
                  />
                  <p className="text-slate-500 text-xs mt-1">
                    Format: {'{ "options": ["A", "B", "C", "D"], "answer": 0, "explanation": "..." }'} · indeks 0–3
                  </p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="text-xs text-slate-500 block mb-1">Difficulty (1–3)</label>
                    <select
                      value={editingQuiz.difficulty}
                      onChange={e => setEditingQuiz({ ...editingQuiz, difficulty: e.target.value })}
                      className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white"
                    >
                      <option value="1">1 — Mudah</option>
                      <option value="2">2 — Sedang</option>
                      <option value="3">3 — Tinggi</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-xs text-slate-500 block mb-1">Jawaban Alternatif (opsional)</label>
                    <textarea
                      rows={3}
                      value={editingQuiz.alternative_answers_text}
                      onChange={e => setEditingQuiz({ ...editingQuiz, alternative_answers_text: e.target.value })}
                      className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white resize-none"
                    />
                  </div>
                </div>
                <div className="flex gap-2">
                  <button type="submit" disabled={busy} className="flex items-center justify-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-xl font-medium disabled:opacity-50">
                    <Save className="w-4 h-4" /> {editingQuiz.id ? 'Simpan Perubahan' : 'Tambah Kuis'}
                  </button>
                  {editingQuiz.id && (
                    <button type="button" onClick={() => setEditingQuiz(EMPTY_QUIZ)} className="px-5 py-2.5 bg-slate-800 text-slate-300 rounded-xl font-medium">
                      Batal
                    </button>
                  )}
                </div>
              </div>
            </form>

            <div className="space-y-4">
              {kuis.map(e => (
                <div key={e.id} className="bg-slate-900 border border-slate-800 p-5 rounded-2xl shadow-xl flex justify-between items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-xs font-mono bg-purple-950 text-purple-400 px-2 py-0.5 rounded-md">{e.type}</span>
                      <span className="text-xs text-slate-500">Difficulty {e.difficulty || 1}</span>
                    </div>
                    <p className="text-white font-medium">{e.prompt}</p>
                    <pre className="mt-2 text-xs text-slate-500 font-mono bg-slate-950 p-2 rounded-lg overflow-x-auto">{JSON.stringify(e.payload, null, 2)}</pre>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => editExercise(e)} className="p-2.5 bg-slate-800 hover:bg-blue-600 text-blue-400 hover:text-white rounded-xl transition-colors">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button onClick={() => deleteExercise(e.id)} className="p-2.5 bg-slate-800 hover:bg-red-600 text-red-400 hover:text-white rounded-xl transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
              {kuis.length === 0 && (
                <div className="text-center py-8 text-slate-500 italic">Belum ada soal kuis.</div>
              )}
            </div>
          </div>
        )}

        {/* Chunk PDF Tab */}
        {activeTab === 'chunk' && (
          <div className="space-y-4">
            <p className="text-slate-400 text-sm">
              Potongan teks hasil ekstraksi modul PDF yang tertaut pada level ini. Digunakan AI sebagai konteks terbatas (maksimal 2 chunk) saat membuat soal dan hint.
            </p>
            {chunks.length === 0 ? (
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8 text-center">
                <p className="text-slate-500 italic">Tidak ada chunk PDF yang tertaut ke level ini.</p>
              </div>
            ) : (
              <div className="space-y-3">
                {chunks.map(chunk => (
                  <div key={chunk.id} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-2">
                          <span className="text-xs font-mono bg-emerald-950 text-emerald-400 px-2 py-0.5 rounded-md">Chunk #{chunk.chunk_order}</span>
                          <span className="text-xs text-slate-500">{chunk.source_title || 'Modul PDF'}</span>
                        </div>
                        <h4 className="text-white font-semibold">{chunk.topic_title || 'Tanpa judul topik'}</h4>
                        <p className="text-slate-400 text-sm mt-1 line-clamp-2">{chunk.content_text.slice(0, 240)}...</p>
                        {chunk.keywords && chunk.keywords.length > 0 && (
                          <div className="flex flex-wrap gap-1 mt-2">
                            {chunk.keywords.slice(0, 8).map((kw, i) => (
                              <span key={i} className="text-[10px] bg-slate-800 text-slate-400 px-2 py-0.5 rounded-full">{kw}</span>
                            ))}
                          </div>
                        )}
                      </div>
                      <div className="flex gap-2">
                        <button onClick={() => setViewChunk(chunk)} className="p-2.5 bg-slate-800 hover:bg-blue-600 text-blue-400 hover:text-white rounded-xl transition-colors" title="Lihat isi lengkap">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button onClick={() => deleteChunk(chunk.id)} className="p-2.5 bg-slate-800 hover:bg-red-600 text-red-400 hover:text-white rounded-xl transition-colors" title="Hapus chunk">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Chunk viewer modal */}
        {viewChunk && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
            <div className="bg-slate-900 border border-slate-700 rounded-2xl p-6 w-full max-w-3xl shadow-2xl max-h-[85vh] flex flex-col">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-xl font-bold text-white">{viewChunk.topic_title || 'Potongan Materi'}</h2>
                  <p className="text-slate-400 text-xs mt-1">
                    {viewChunk.source_title || 'Modul PDF'} · Chunk #{viewChunk.chunk_order}
                  </p>
                </div>
                <button onClick={() => setViewChunk(null)} className="text-slate-400 hover:text-white transition-colors">
                  <X className="w-5 h-5" />
                </button>
              </div>
              <pre className="flex-1 overflow-auto bg-slate-950 p-4 rounded-xl text-slate-300 text-sm whitespace-pre-wrap font-sans">
                {viewChunk.content_text}
              </pre>
              <button onClick={() => setViewChunk(null)} className="mt-4 w-full px-4 py-2.5 bg-slate-800 hover:bg-slate-700 text-white rounded-xl font-medium">
                Tutup
              </button>
            </div>
          </div>
        )}
      </div>
    </AdminShell>
  )
}