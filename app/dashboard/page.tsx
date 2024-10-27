'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/components/auth/auth-provider'
import { DashboardHeader } from '@/components/dashboard/dashboard-header'
import { MessageList } from '@/components/messages/message-list'
import { NewMessageCard } from '@/components/messages/new-message-card'

export default function DashboardPage() {
  const { user, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login')
    }
  }, [loading, user, router])

  if (loading) {
    return <div className="flex items-center justify-center min-h-screen">Loading...</div>
  }

  if (!user) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-neutral-50 to-neutral-100 dark:from-neutral-950 dark:to-neutral-900">
      <DashboardHeader />
      <main className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-2 gap-8">
          <MessageList />
          <NewMessageCard />
        </div>
      </main>
    </div>
  )
}