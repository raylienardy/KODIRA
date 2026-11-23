'use client'

import { useState, useEffect } from 'react'
import AdminShell from '@/components/AdminShell'
import { createBrowserClient } from '@/lib/supabase/client'
import { Download, Filter } from 'lucide-react'

interface StudentRow {
  nim?: string
  name?: string
  className?: string
  xp: number
  rank: string
  streak: number
}

interface SupabaseResponseItem {
  student_id: string
  classes?: { name?: string } | Array<{ name?: string }>
  users?: { nim?: string; name?: string } | Array<{ nim?: string; name?: string }>
  user_progress?: Array<{ xp_earned?: number }>
  user_streaks?: { current_streak?: number } | Array<{ current_streak?: number }>
}

export default function StudentsPage() {
  const [students, setStudents] = useState<StudentRow[]>([])
  const supabase = createBrowserClient()

  useEffect(() => {
    let active = true
    const load = async () => {
      const { data } = await supabase
        .from('class_students')
        .select(`
          student_id,
          classes(name),
          users(nim, name),
          user_progress(xp_earned),
          user_streaks(current_streak)
        `)
      
      if (data && active) {
        const typedData = data as unknown as SupabaseResponseItem[]
        const processed = typedData.map((item) => {
          const xp = Array.isArray(item.user_progress)
            ? item.user_progress.reduce((acc: number, curr: { xp_earned?: number }) => acc + (curr.xp_earned || 0), 0)
            : 0
          let rank = 'Rookie Coder'
          if (xp >= 2000) rank = 'Tech Grandmaster'
          else if (xp >= 1000) rank = 'Logic Master'
          else if (xp >= 500) rank = 'Code Explorer'
          else if (xp >= 200) rank = 'Junior Dev'

          const userObj = Array.isArray(item.users) ? item.users[0] : item.users
          const classObj = Array.isArray(item.classes) ? item.classes[0] : item.classes
          const streakObj = Array.isArray(item.user_streaks) ? item.user_streaks[0] : item.user_streaks
          
          return {
            nim: userObj?.nim || '-',
            name: userObj?.name || '-',
            className: classObj?.name || '-',
            xp,
            rank,
            streak: streakObj?.current_streak || 0
          }
        })
        setStudents(processed)
      }
    }
    load()
    return () => {
      active = false
    }
  }, [supabase])

  const exportCSV = () => {
    const headers = ['NIM', 'Nama', 'Kelas', 'Rank', 'Total XP', 'Streak']
    const rows = students.map(s => [s.nim, s.name, s.className, s.rank, s.xp, s.streak])
    const csvContent = [
      headers.join(','),
      ...rows.map(r => r.join(','))
    ].join('\n')
    
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
        
        <div className="flex gap-4">
          <input type="text" placeholder="Cari NIM/Nama..." className="px-4 py-2 bg-slate-900 border border-slate-800 rounded-xl text-white flex-1" />
          <button className="flex items-center gap-2 px-4 py-2 bg-slate-800 text-white rounded-xl"><Filter className="w-4 h-4"/> Filter Kelas</button>
          <button onClick={exportCSV} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-xl"><Download className="w-4 h-4"/> Export CSV</button>
        </div>

        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-slate-500 uppercase text-xs">
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
              {students.map((s, i) => (
                <tr key={i}>
                  <td className="px-4 py-4">{s.nim}</td>
                  <td className="px-4 py-4 font-medium text-white">{s.name}</td>
                  <td className="px-4 py-4">{s.className}</td>
                  <td className="px-4 py-4 text-blue-400">{s.rank}</td>
                  <td className="px-4 py-4">{s.xp}</td>
                  <td className="px-4 py-4">{s.streak}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminShell>
  )
}
