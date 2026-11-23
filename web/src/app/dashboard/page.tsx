import { Suspense } from 'react'
import AdminShell from '@/components/AdminShell'
import { createServerClient } from '@/lib/supabase/server'
import { LayoutDashboard, Users, BookOpenText, Layers, ArrowRight } from 'lucide-react'
import { connection } from 'next/server'
import Link from 'next/link'

export default function DashboardPage() {
  return (
    <AdminShell>
      <Suspense fallback={<div className="p-8 text-slate-400">Loading Dashboard...</div>}>
        <DashboardContent />
      </Suspense>
    </AdminShell>
  )
}

async function DashboardContent() {
  // connection() harus dipanggil paling awal sebelum query apa pun agar
  // komponen dinamis Next.js 16 (cacheComponents: true) tidak gagal
  // prerender saat proses build (misal karena Date.now() di library).
  await connection()
  const supabase = await createServerClient()

  const [
    { count: totalClasses },
    { count: totalStudents },
    { count: totalLevels },
    { data: classes },
    { data: progress },
  ] = await Promise.all([
    supabase.from('classes').select('*', { count: 'exact', head: true }),
    supabase.from('users').select('*', { count: 'exact', head: true }).eq('role', 'student'),
    supabase.from('levels').select('*', { count: 'exact', head: true }),
    supabase.from('classes').select('id, name, code, description').order('name'),
    supabase.from('user_progress').select('user_id, xp_earned'),
  ])

  let avgXp: number | string = 0
  if (progress && progress.length > 0) {
    const studentXpMap: Record<string, number> = {}
    progress.forEach((p) => {
      studentXpMap[p.user_id] = (studentXpMap[p.user_id] || 0) + (p.xp_earned || 0)
    })
    const uniqueStudentsWithProgress = Object.keys(studentXpMap).length
    const totalXp = Object.values(studentXpMap).reduce((a, b) => a + b, 0)
    avgXp = uniqueStudentsWithProgress > 0 ? Math.round(totalXp / uniqueStudentsWithProgress) : 0
  }

  const kpi = [
    { name: 'Total Kelas', value: totalClasses || 0, icon: BookOpenText, href: '/classes' },
    { name: 'Total Mahasiswa', value: totalStudents || 0, icon: Users, href: '/students' },
    { name: 'Rata-rata XP', value: avgXp, icon: LayoutDashboard, href: '/students' },
    { name: 'Total Level', value: totalLevels || 0, icon: Layers, href: '/levels' },
  ]

  return (
    <div className="space-y-8">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-bold text-white">Dashboard Monitoring</h1>
        <div className="flex flex-wrap gap-3">
          <Link href="/classes" className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-sm font-medium transition-colors border border-slate-700">
            Kelas <ArrowRight className="w-4 h-4" />
          </Link>
          <Link href="/students" className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-sm font-medium transition-colors border border-slate-700">
            Mahasiswa <ArrowRight className="w-4 h-4" />
          </Link>
          <Link href="/levels" className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-sm font-medium transition-colors border border-slate-700">
            Level <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpi.map((item) => {
          const Icon = item.icon
          return (
            <Link href={item.href} key={item.name} className="bg-slate-900 border border-slate-800 hover:border-blue-500/50 rounded-2xl p-6 shadow-xl transition-all group">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-blue-600/20 group-hover:bg-blue-600/30 rounded-xl text-blue-400 transition-colors">
                  <Icon className="w-6 h-6" />
                </div>
                <div>
                  <p className="text-sm text-slate-400">{item.name}</p>
                  <p className="text-2xl font-bold text-white">{item.value}</p>
                </div>
              </div>
            </Link>
          )
        })}
      </div>

      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
        <h2 className="text-lg font-bold text-white mb-6">Kelas Aktif</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-slate-500 uppercase tracking-wider text-xs">
              <tr>
                <th className="px-4 py-3">Nama Kelas</th>
                <th className="px-4 py-3">Kode</th>
                <th className="px-4 py-3">Deskripsi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {classes?.map((cls) => (
                <tr key={cls.id} className="hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 py-4 font-medium text-white">{cls.name}</td>
                  <td className="px-4 py-4 font-mono text-blue-400">{cls.code}</td>
                  <td className="px-4 py-4 text-slate-400">{cls.description || '-'}</td>
                </tr>
              ))}
              {(!classes || classes.length === 0) && (
                <tr>
                  <td colSpan={3} className="px-4 py-8 text-center text-slate-500 italic">Belum ada kelas yang dibuat</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
