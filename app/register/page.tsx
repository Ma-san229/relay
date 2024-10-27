import { AuthForm } from '@/components/auth/auth-form'

export default function RegisterPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-neutral-50 to-neutral-100 dark:from-neutral-950 dark:to-neutral-900 p-4">
      <AuthForm type="register" />
    </div>
  )
}