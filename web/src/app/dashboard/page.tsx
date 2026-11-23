import { Suspense } from 'react'
import AdminShell from '@/components/AdminShell'
import { createServerClient } from '@/lib/supabase/server'
import { LayoutDashboard, Users, BookOpenText, Layers } from 'lucide-react'

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
  const supabase = await createServerClient()
  
  // Fetch KPI Data
  const { count: totalClasses } = await supabase.from('classes').select('*', { count: 'exact' })
  const { count: totalStudents } = await supabase.from('users').select('*', { count: 'exact' }).eq('role', 'student')
  const { count: totalLevels } = await supabase.from('levels').select('*', { count: 'exact' })
  
  // Fetch classes
  const { data: classes } = await supabase
    .from('classes')
    .select('id, name, code, description')
    .order('name')
  
  // Calculate average XP (Simplified approach: fetch all student progress)
  const { data: progress } = await supabase.from('user_progress').select('xp_earned')
  const avgXp = progress && progress.length > 0 
    ? (progress.reduce((acc, curr) => acc + (curr.xp_earned || 0), 0) / progress.length).toFixed(0)
    : 0

  const kpi = [
    { name: 'Total Kelas', value: totalClasses || 0, icon: BookOpenText },
    { name: 'Total Mahasiswa', value: totalStudents || 0, icon: Users },
    { name: 'Rata-rata XP', value: avgXp, icon: LayoutDashboard },
    { name: 'Total Level', value: totalLevels || 0, icon: Layers },
  ]

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-white">Dashboard Monitoring</h1>
      
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpi.map((item) => {
          const Icon = item.icon
          return (
            <div key={item.name} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-blue-600/20 rounded-xl text-blue-400">
                  <Icon className="w-6 h-6" />
                </div>
                <div>
                  <p className="text-sm text-slate-400">{item.name}</p>
                  <p className="text-2xl font-bold text-white">{item.value}</p>
                </div>
              </div>
            </div>
          )
        })}
      </div>
      
      {/* Class List */}
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
              {classes?.map(cls => (
                <tr key={cls.id}>
                  <td className="px-4 py-4 font-medium text-white">{cls.name}</td>
                  <td className="px-4 py-4 font-mono text-blue-400">{cls.code}</td>
                  <td className="px-4 py-4 text-slate-400">{cls.description || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
