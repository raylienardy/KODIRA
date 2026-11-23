'use client'

import { useState, useEffect, useCallback } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { ArrowDown, ArrowUp, BookUp, FileUp, Loader2, Plus, X } from 'lucide-react'
import { extractChunksFromFile } from '@/lib/pdf/extractChunks'
import Link from 'next/link'

interface ClassInfo {
  id: string
  name: string
  code?: string | null
}

interface ClassTeacherRow {
  class_id: string
}

interface LevelData {
  id: number
  level_number: number
  title: string
  description?: string | null
  topic?: string | null
  difficulty?: number | null
}

interface PdfProcessResult {
  success: boolean
  processed_chunks: number
  created_levels: number
  attached_levels: number
  levels: Array<{ id: number; level_number: number; title: string }>
  message?: string
}

export default function LevelsPage() {
  const supabase = createBrowserClient()
  const [classes, setClasses] = useState<ClassInfo[]>([])
  const [levels, setLevels] = useState<LevelData[]>([])
  const [selectedClass, setSelectedClass] = useState<string>('')
  const [newLevel, setNewLevel] = useState({
    level_number: '',
    title: '',
    description: '',
    difficulty: '1',
  })
  const [busy, setBusy] = useState(false)
  const [notification, setNotification] = useState<{ type: 'success' | 'error'; message: string } | null>(null)
  const [showPdfModal, setShowPdfModal] = useState(false)
  const [pdfFile, setPdfFile] = useState<File | null>(null)
  const [pdfLanguage, setPdfLanguage] = useState<'cpp' | 'java'>('cpp')
  const [uploadStatus, setUploadStatus] = useState('')
  const [pdfResult, setPdfResult] = useState<PdfProcessResult | null>(null)

  const loadLevels = useCallback(async (classId: string) => {
    if (!classId) {
      setLevels([])
      return
    }
    const { data } = await supabase
      .from('levels')
      .select('id, level_number, title, description, topic, difficulty')
      .eq('class_id', classId)
      .order('level_number', { ascending: true })
    if (data) setLevels(data as LevelData[])
  }, [supabase])

  useEffect(() => {
    let active = true
    const load = async () => {
      const { data: userData } = await supabase.auth.getUser()
      const userId = userData?.user?.id
      if (!userId) return

      // Query terpisah: class_teachers lalu classes (hindari nested join 400)
      const { data: teacherRows } = await supabase
        .from('class_teachers')
        .select('class_id')
        .eq('teacher_id', userId)

      if (!teacherRows || teacherRows.length === 0) {
        if (active) setClasses([])
        return
      }

      const classIds = Array.from(new Set((teacherRows as ClassTeacherRow[]).map((r) => r.class_id)))
      const { data: classRows } = await supabase
        .from('classes')
        .select('id, name, code')
        .in('id', classIds)

      if (!active) return
      const list = (classRows || []) as ClassInfo[]
      setClasses(list)
      if (list.length > 0) setSelectedClass((current) => current || list[0].id)
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  useEffect(() => {
    let active = true
    const load = async () => {
      if (!selectedClass) {
        if (active) setLevels([])
        return
      }
      const { data } = await supabase
        .from('levels')
        .select('id, level_number, title, description, topic, difficulty')
        .eq('class_id', selectedClass)
        .order('level_number', { ascending: true })
      if (data && active) setLevels(data as LevelData[])
    }
    load()
    return () => {
      active = false
    }
  }, [selectedClass, supabase])

  const showNotification = (type: 'success' | 'error', message: string) => {
    setNotification({ type, message })
    setTimeout(() => setNotification(null), 6000)
  }

  const handleCloneTemplate = async () => {
    if (!selectedClass) return
    setBusy(true)
    try {
      const { data, error } = await supabase.rpc('clone_default_curriculum_to_class', {
        p_class_id: selectedClass,
      })
      if (error) throw error
      const count = typeof data === 'number' ? data : 0
      showNotification(
        'success',
        count > 0 ? `Berhasil menyalin ${count} level template.` : 'Kelas sudah memiliki level. Tidak ada yang disalin.',
      )
      await loadLevels(selectedClass)
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menyalin template.')
    } finally {
      setBusy(false)
    }
  }

  const handleShiftLevels = async (direction: 'up' | 'down') => {
    if (!selectedClass || levels.length === 0) return
    const sorted = [...levels].sort((a, b) => a.level_number - b.level_number)
    const fromLevel = direction === 'up' ? sorted[0].level_number : sorted[sorted.length - 1].level_number + 1
    setBusy(true)
    try {
      const { error } = await supabase.rpc('shift_class_levels', {
        p_class_id: selectedClass,
        p_from_level_number: fromLevel,
        p_delta: direction === 'up' ? -1 : 1,
      })
      if (error) throw error
      showNotification('success', `Urutan level berhasil digeser ${direction === 'up' ? 'naik' : 'turun'}.`)
      await loadLevels(selectedClass)
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menggeser urutan level.')
    } finally {
      setBusy(false)
    }
  }

  const handleManualAddLevel = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedClass) return
    setBusy(true)
    try {
      const levelNumber = parseInt(newLevel.level_number, 10)
      if (Number.isNaN(levelNumber) || levelNumber < 1) {
        throw new Error('Nomor level harus bilangan positif.')
      }
      const { error } = await supabase.from('levels').insert({
        class_id: selectedClass,
        level_number: levelNumber,
        title: newLevel.title,
        description: newLevel.description,
        difficulty: parseInt(newLevel.difficulty, 10),
      })
      if (error) throw error
      setNewLevel({ level_number: '', title: '', description: '', difficulty: '1' })
      showNotification('success', 'Level baru berhasil ditambahkan.')
      await loadLevels(selectedClass)
    } catch (err) {
      showNotification('error', err instanceof Error ? err.message : 'Gagal menambah level.')
    } finally {
      setBusy(false)
    }
  }

  const handleProcessPdf = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedClass || !pdfFile) return
    setBusy(true)
    setPdfResult(null)
    setUploadStatus('Mengekstrak teks dari PDF di browser...')
    try {
      const chunks = await extractChunksFromFile(pdfFile)
      if (chunks.length === 0) {
        throw new Error('Tidak ada teks yang dapat diekstrak dari PDF.')
      }

      setUploadStatus(`Mengirim ${chunks.length} potongan teks ke AI processor...`)
      const { data, error } = await supabase.functions.invoke('ai-process-pdf', {
        body: {
          class_id: selectedClass,
          source_title: pdfFile.name,
          language: pdfLanguage,
          chunks,
        },
      })
      if (error) throw error

      const result = data as PdfProcessResult
      setPdfResult(result)
      setUploadStatus('')
      setPdfFile(null)
      showNotification('success', 'Modul PDF berhasil diproses.')
      await loadLevels(selectedClass)
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Gagal memproses PDF.'
      setUploadStatus('')
      setPdfResult({ success: false, processed_chunks: 0, created_levels: 0, attached_levels: 0, levels: [], message })
      showNotification('error', message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <AdminShell>
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-white">Manajemen Kurikulum Per-Kelas</h1>

        {notification && (
          <div className={`px-4 py-3 rounded-xl text-sm ${
            notification.type === 'success'
              ? 'bg-emerald-500/15 border border-emerald-500/30 text-emerald-300'
              : 'bg-red-500/15 border border-red-500/30 text-red-300'
          }`}>
            {notification.message}
          </div>
        )}

        {/* Class selector & actions panel */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-5">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
            <div>
              <label className="text-xs text-slate-500 block mb-2">Kelas Aktif</label>
              <select
                value={selectedClass}
                onChange={(e) => setSelectedClass(e.target.value)}
                disabled={busy}
                className="w-full px-4 py-3 bg-slate-950 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-blue-500"
              >
                <option value="">-- Pilih Kelas --</option>
                {classes.map((cls) => (
                  <option key={cls.id} value={cls.id}>
                    {cls.code ? `${cls.code} — ${cls.name}` : cls.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex items-end gap-2">
              <button
                onClick={handleCloneTemplate}
                disabled={!selectedClass || busy}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
              >
                <BookUp className="w-4 h-4" /> Salin Template 15 Level
              </button>
              <button
                onClick={() => { setShowPdfModal(true); setPdfResult(null); setUploadStatus('') }}
                disabled={!selectedClass || busy}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
              >
                <FileUp className="w-4 h-4" /> Upload Modul PDF
              </button>
            </div>

            <div className="flex items-end justify-center gap-2">
              <button
                onClick={() => handleShiftLevels('up')}
                disabled={!selectedClass || levels.length === 0 || busy}
                title="Geser urutan ke atas"
                className="flex items-center justify-center gap-1 px-4 py-3 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl font-medium transition-colors disabled:opacity-50"
              >
                <ArrowUp className="w-4 h-4" /> Naik
              </button>
              <button
                onClick={() => handleShiftLevels('down')}
                disabled={!selectedClass || levels.length === 0 || busy}
                title="Geser urutan ke bawah"
                className="flex items-center justify-center gap-1 px-4 py-3 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl font-medium transition-colors disabled:opacity-50"
              >
                <ArrowDown className="w-4 h-4" /> Turun
              </button>
            </div>
          </div>

          {/* Manual add level form */}
          <form onSubmit={handleManualAddLevel} className="border-t border-slate-800 pt-5">
            <h2 className="text-sm font-semibold text-white mb-4">Tambah Level Manual</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
              <input
                type="number"
                min={1}
                placeholder="No. Level"
                value={newLevel.level_number}
                onChange={e => setNewLevel({ ...newLevel, level_number: e.target.value })}
                className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                required
                disabled={!selectedClass || busy}
              />
              <input
                type="text"
                placeholder="Judul level"
                value={newLevel.title}
                onChange={e => setNewLevel({ ...newLevel, title: e.target.value })}
                className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 sm:col-span-2"
                required
                disabled={!selectedClass || busy}
              />
              <select
                value={newLevel.difficulty}
                onChange={e => setNewLevel({ ...newLevel, difficulty: e.target.value })}
                className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-blue-500"
                disabled={!selectedClass || busy}
              >
                <option value="1">1 — Mudah</option>
                <option value="2">2 — Sedang</option>
                <option value="3">3 — Tinggi</option>
              </select>
              <button
                type="submit"
                disabled={!selectedClass || busy}
                className="flex items-center justify-center gap-2 px-4 py-2.5 bg-slate-800 hover:bg-slate-700 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
              >
                <Plus className="w-4 h-4" /> Tambah
              </button>
              <input
                type="text"
                placeholder="Deskripsi (opsional)"
                value={newLevel.description}
                onChange={e => setNewLevel({ ...newLevel, description: e.target.value })}
                className="px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 lg:col-span-5"
                disabled={!selectedClass || busy}
              />
            </div>
          </form>
        </div>

        {/* PDF Upload Modal */}
        {showPdfModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
            <div className="bg-slate-900 border border-slate-700 rounded-2xl p-6 w-full max-w-lg shadow-2xl">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-white">Upload Modul PDF (AI Generator)</h2>
                <button
                  onClick={() => setShowPdfModal(false)}
                  disabled={busy}
                  className="text-slate-400 hover:text-white transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              <p className="text-slate-400 text-sm mb-5">
                File PDF diproses sepenuhnya di browser. Hanya potongan teks yang dikirim ke AI — file biner tidak pernah diunggah ke server.
              </p>

              <form onSubmit={handleProcessPdf} className="space-y-4">
                <div>
                  <label className="text-xs text-slate-500 block mb-2">File PDF Modul</label>
                  <input
                    type="file"
                    accept=".pdf,application/pdf"
                    onChange={e => setPdfFile(e.target.files?.[0] || null)}
                    disabled={busy}
                    className="w-full text-sm text-slate-300 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:bg-slate-800 file:text-slate-200 hover:file:bg-slate-700"
                  />
                </div>
                <div>
                  <label className="text-xs text-slate-500 block mb-2">Bahasa Pemrograman</label>
                  <select
                    value={pdfLanguage}
                    onChange={e => setPdfLanguage(e.target.value as 'cpp' | 'java')}
                    disabled={busy}
                    className="w-full px-4 py-2.5 bg-slate-950 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-blue-500"
                  >
                    <option value="cpp">C++</option>
                    <option value="java">Java</option>
                  </select>
                </div>

                {uploadStatus && (
                  <div className="flex items-center gap-2 px-3 py-2 bg-blue-500/10 border border-blue-500/20 rounded-xl text-blue-300 text-sm">
                    <Loader2 className="w-4 h-4 animate-spin" /> {uploadStatus}
                  </div>
                )}

                <button
                  type="submit"
                  disabled={!pdfFile || busy}
                  className="w-full flex items-center justify-center gap-2 px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
                >
                  <FileUp className="w-4 h-4" /> Ekstrak & Proses dengan AI
                </button>
              </form>

              {pdfResult && (
                <div className="mt-5 p-4 bg-slate-800 rounded-xl">
                  <h3 className={`font-semibold mb-3 ${pdfResult.success ? 'text-emerald-400' : 'text-red-400'}`}>
                    {pdfResult.success ? 'Ringkasan Pemrosesan' : 'Pemrosesan Gagal'}
                  </h3>
                  {pdfResult.success ? (
                    <div className="grid grid-cols-3 gap-3 text-center">
                      <div>
                        <p className="text-2xl font-bold text-emerald-400">{pdfResult.processed_chunks}</p>
                        <p className="text-slate-400 text-xs">Chunk Diproses</p>
                      </div>
                      <div>
                        <p className="text-2xl font-bold text-blue-400">{pdfResult.created_levels}</p>
                        <p className="text-slate-400 text-xs">Level Baru</p>
                      </div>
                      <div>
                        <p className="text-2xl font-bold text-amber-400">{pdfResult.attached_levels}</p>
                        <p className="text-slate-400 text-xs">Level Ditautkan</p>
                      </div>
                    </div>
                  ) : (
                    <p className="text-red-300 text-sm">{pdfResult.message}</p>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Levels list */}
        {selectedClass && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-white">Daftar Level</h2>
              <span className="text-slate-400 text-xs">{levels.length} level</span>
            </div>
            {levels.length === 0 ? (
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8 text-center">
                <p className="text-slate-500 italic">
                  Belum ada level di kelas ini. Salin template atau unggah modul PDF untuk memulai.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                {levels.map((level) => (
                  <div
                    key={level.id}
                    className="bg-slate-900 border border-slate-800 hover:border-blue-500/50 rounded-2xl p-5 shadow-xl transition-colors"
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span className="bg-blue-600/20 text-blue-400 text-xs font-bold px-2.5 py-1 rounded-md">
                        Level {level.level_number}
                      </span>
                      {level.topic && (
                        <span className="text-xs text-slate-500 truncate">{level.topic}</span>
                      )}
                    </div>
                    <h3 className="text-white font-bold">{level.title}</h3>
                    {level.description && (
                      <p className="text-slate-400 text-sm mt-1 line-clamp-2">{level.description}</p>
                    )}
                    <Link
                      href={`/levels/${level.id}`}
                      className="mt-4 inline-flex items-center gap-1 text-blue-400 hover:text-blue-300 text-sm font-medium"
                    >
                      Edit materi, latihan & kuis →
                    </Link>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </AdminShell>
  )
}