import { AlertCircle, Eye, EyeOff, Loader2 } from 'lucide-react'
import { useLoginForm } from '../model/useLoginForm'

const AuthWidget = () => {
  const {
    email,
    password,
    showPassword,
    error,
    loading,
    setEmail,
    setPassword,
    setShowPassword,
    handleSubmit
  } = useLoginForm()

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-zinc-950">
      {/* ── Left decorative panel ── */}
      <div className="hidden lg:flex relative overflow-hidden flex-col justify-end p-14">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{
            backgroundImage:
              "url('https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1000&auto=format&fit=crop&q=80')"
          }}
        />
        <div className="absolute inset-0 bg-linear-to-t from-zinc-950 via-zinc-950/60 to-zinc-950/10" />

        <div className="relative z-10 space-y-5">
          {/* brand mark */}
          <div className="w-9 h-9 border border-amber-500/50 rotate-45 flex items-center justify-center">
            <div className="w-3.5 h-3.5 bg-amber-500 -rotate-45" />
          </div>
          <div>
            <h1 className="text-[44px] font-light text-white leading-[1.2] tracking-tight">
              Manage
              <br />
              real estate
              <br />
              <span className="text-amber-400">efficiently.</span>
            </h1>
            <p className="mt-3 text-[11px] tracking-[0.15em] uppercase text-zinc-500">
              Real Estate CRM — platform for agents
            </p>
          </div>
        </div>
      </div>

      {/* ── Right form panel ── */}
      <div className="flex items-center justify-center px-6 py-16 lg:px-16 bg-zinc-900 border-l border-zinc-800">
        <div className="w-full max-w-sm">
          {/* Heading */}
          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-white tracking-tight">
              Sign in
            </h2>
            <p className="mt-1.5 text-sm text-zinc-500">
              Enter your credentials
            </p>
          </div>

          {/* Error banner */}
          {error && (
            <div className="flex items-start gap-2.5 rounded-md bg-red-950/50 border border-red-800/40 px-3.5 py-3 mb-6 text-sm text-red-400">
              <AlertCircle size={16} className="mt-0.5 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} noValidate className="space-y-5">
            {/* Email field */}
            <div className="space-y-1.5">
              <label
                htmlFor="login-email"
                className="block text-[11px] font-medium tracking-[0.12em] uppercase text-zinc-500"
              >
                Email
              </label>
              <input
                id="login-email"
                type="email"
                placeholder="agent@company.kz"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full rounded-md bg-zinc-800/60 border border-zinc-700 px-3.5 py-2.5 text-sm text-white placeholder:text-zinc-600 outline-none focus:border-amber-500 focus:bg-zinc-800 transition-colors"
              />
            </div>

            {/* Password field */}
            <div className="space-y-1.5">
              <label
                htmlFor="login-password"
                className="block text-[11px] font-medium tracking-[0.12em] uppercase text-zinc-500"
              >
                Password
              </label>
              <div className="relative">
                <input
                  id="login-password"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="••••••••"
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full rounded-md bg-zinc-800/60 border border-zinc-700 px-3.5 py-2.5 pr-10 text-sm text-white placeholder:text-zinc-600 outline-none focus:border-amber-500 focus:bg-zinc-800 transition-colors"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-amber-400 transition-colors"
                >
                  {showPassword ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            {/* Submit */}
            <button
              type="submit"
              disabled={loading}
              className="w-full flex items-center justify-center gap-2 rounded-md bg-amber-500 hover:bg-amber-400 active:scale-[0.99] disabled:opacity-60 disabled:cursor-not-allowed px-4 py-2.5 text-sm font-medium text-zinc-900 tracking-wide uppercase transition-all mt-1"
            >
              {loading && <Loader2 size={16} className="animate-spin" />}
              {loading ? 'Signing in...' : 'Sign in'}
            </button>
          </form>

          {/* Footer */}
          <div className="mt-8 pt-6 border-t border-zinc-800 text-center text-xs text-zinc-600 leading-relaxed">
            No access? Contact your administrator.
            <br />
            Registration via{' '}
            <code className="text-zinc-500 font-mono">/auth/register</code>.
          </div>
        </div>
      </div>
    </div>
  )
}

export default AuthWidget
