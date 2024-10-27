'use client'

import { useAuth } from '@/components/auth/auth-provider'
import { Button } from '@/components/ui/button'
import { supabase } from '@/lib/supabase'
import { useRouter } from 'next/navigation'
import { LogOut } from 'lucide-react'

export function DashboardHeader() {
  const { user } = useAuth()
  const router = useRouter()

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/')
  }

  return (
    <header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-pink-500 via-red-500 to-yellow-500 text-transparent bg-clip-text">
          メモリーリレー
        </h1>
        <div className="flex items-center gap-4">
          <span className="text-sm text-muted-foreground">
            {user?.email}
          </span>
          <Button variant="ghost" size="icon" onClick={handleSignOut}>
            <LogOut className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  )
}