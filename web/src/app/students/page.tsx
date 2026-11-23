'use client'

import { useState, useEffect } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { Download, Search } from 'lucide-react'

interface StudentRow {
  student_id: string
  nim: string
  name: string
  className: string
  xp: number
  rank: string
  streak: number
}

interface ClassInfo {
  id: string
  name: string
}

interface UserInfo {
  id: string
  nim: string
  name: string
}

interface ProgressRow {
  user_id: string
  xp_earned: number
}

interface StreakRow {
  user_id: string
  current_streak: number
}

interface ClassStudentRow {
  student_id: string
  class_id: string
}

export default function StudentsPage() {
  const [students, setStudents] = useState<StudentRow[]>([])
  const [search, setSearch] = useState('')
  const [selectedClass, setSelectedClass] = useState('')
  const [classList, setClassList] = useState<string[]>([])
  const supabase = createBrowserClient()

  useEffect(() => {
    let active = true
    const load = async () => {
      // Query terpisah (tanpa nested join) agar tidak memicu HTTP 400 Bad Request.
      const { data: csData } = await supabase
        .from('class_students')
        .select('student_id, class_id')

      if (!csData || csData.length === 0) {
        if (active) {
          setStudents([])
          setClassList([])
        }
        return
      }

      const csRows = csData as unknown as ClassStudentRow[]
      const studentIds = Array.from(new Set(csRows.map((r) => r.student_id)))

      const [usersRes, progressRes, streakRes, classRes] = await Promise.all([
        supabase.from('users').select('id, nim, name').in('id', studentIds),
        supabase.from('user_progress').select('user_id, xp_earned').in('user_id', studentIds),
        supabase.from('user_streaks').select('user_id, current_streak').in('user_id', studentIds),
        supabase.from('classes').select('id, name'),
      ])

      if (!active) return

      const usersMap = new Map<string, UserInfo>()
      ;(usersRes.data as unknown as UserInfo[] | null)?.forEach((u) => {
        usersMap.set(u.id, u)
      })

      const classMap = new Map<string, string>()
      const classNames: string[] = []
      ;(classRes.data as unknown as ClassInfo[] | null)?.forEach((c) => {
        classMap.set(c.id, c.name)
        classNames.push(c.name)
      })

      const xpMap: Record<string, number> = {}
      ;(progressRes.data as unknown as ProgressRow[] | null)?.forEach((p) => {
        xpMap[p.user_id] = (xpMap[p.user_id] || 0) + (p.xp_earned || 0)
      })

      const streakMap: Record<string, number> = {}
      ;(streakRes.data as unknown as StreakRow[] | null)?.forEach((s) => {
        streakMap[s.user_id] = s.current_streak || 0
      })

      const processed: StudentRow[] = csRows.map((row) => {
        const user = usersMap.get(row.student_id)
        const xp = xpMap[row.student_id] || 0

        let rank = 'Rookie Coder'
        if (xp >= 2000) rank = 'Tech Grandmaster'
        else if (xp >= 1000) rank = 'Logic Master'
        else if (xp >= 500) rank = 'Code Explorer'
        else if (xp >= 200) rank = 'Junior Dev'

        return {
          student_id: row.student_id,
          nim: user?.nim || '-',
          name: user?.name || '-',
          className: classMap.get(row.class_id) || '-',
          xp,
          rank,
          streak: streakMap[row.student_id] || 0,
        }
      })

      if (active) {
        setStudents(processed)
        setClassList(classNames)
      }
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  const filteredStudents = students.filter((s) => {
    const matchSearch =
      s.name.toLowerCase().includes(search.toLowerCase()) ||
      s.nim.toLowerCase().includes(search.toLowerCase())
    const matchClass = selectedClass ? s.className === selectedClass : true
    return matchSearch && matchClass
  })

  const exportCSV = () => {
    const headers = ['NIM', 'Nama', 'Kelas', 'Rank', 'Total XP', 'Streak']
    const rows = filteredStudents.map((s) => [s.nim, s.name, s.className, s.rank, s.xp, s.streak])
    const csvContent = [headers.join(','), ...rows.map((r) => r.join(','))].join('\n')

    const blob = new Blob([csvContent], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'mahasiswa.csv'
    a.click()
  }

  return (
    <AdminShell>
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-white">Data Mahasiswa</h1>

        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-4 top-3.5 w-4 h-4 text-slate-500" />
            <input
              type="text"
              placeholder="Cari NIM/Nama..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-11 pr-4 py-3 bg-slate-900 border border-slate-800 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
            />
          </div>

          <div className="flex items-center gap-3">
            <select
              value={selectedClass}
              onChange={(e) => setSelectedClass(e.target.value)}
              className="px-4 py-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-blue-500"
            >
              <option value="">Semua Kelas</option>
              {classList.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>

            <button
              onClick={exportCSV}
              className="flex items-center gap-2 px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-medium transition-colors shadow-lg shadow-blue-600/20"
            >
              <Download className="w-4 h-4" /> Export CSV
            </button>
          </div>
        </div>

        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-slate-500 uppercase text-xs border-b border-slate-800">
              <tr>
                <th className="px-4 py-3">NIM</th>
                <th className="px-4 py-3">Nama</th>
                <th className="px-4 py-3">Kelas</th>
                <th className="px-4 py-3">Rank</th>
                <th className="px-4 py-3">XP</th>
                <th className="px-4 py-3">Streak</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {filteredStudents.map((s) => (
                <tr key={s.student_id} className="hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 py-4 font-mono text-slate-400">{s.nim}</td>
                  <td className="px-4 py-4 font-medium text-white">{s.name}</td>
                  <td className="px-4 py-4 text-slate-400">{s.className}</td>
                  <td className="px-4 py-4 font-semibold text-blue-400">{s.rank}</td>
                  <td className="px-4 py-4 text-emerald-400">{s.xp}</td>
                  <td className="px-4 py-4 text-amber-400">{s.streak} hari</td>
                </tr>
              ))}
              {filteredStudents.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-4 py-8 text-center text-slate-500 italic">
                    Tidak ada mahasiswa yang ditemukan
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
