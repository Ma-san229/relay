'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { useToast } from '@/components/ui/use-toast'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/components/auth/auth-provider'

export function NewMessageCard() {
  const [receiver, setReceiver] = useState('')
  const [content, setContent] = useState('')
  const [sending, setSending] = useState(false)
  const { toast } = useToast()
  const { user } = useAuth()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return

    setSending(true)
    try {
      const { error } = await supabase
        .from('messages')
        .insert([
          {
            sender: user.email,
            receiver,
            content,
          },
        ])

      if (error) throw error

      toast({
        title: '成功',
        description: 'メッセージを送信しました！',
      })
      
      setReceiver('')
      setContent('')
    } catch (error) {
      toast({
        title: 'エラー',
        description: 'メッセージの送信に失敗しました。もう一度お試しください。',
        variant: 'destructive',
      })
    } finally {
      setSending(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>メッセージを送る</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Input
              placeholder="受信者のメールアドレス"
              value={receiver}
              onChange={(e) => setReceiver(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Textarea
              placeholder="メッセージを入力..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
              required
              rows={4}
            />
          </div>
          <Button type="submit" className="w-full" disabled={sending}>
            {sending ? '送信中...' : 'メッセージを送信'}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}