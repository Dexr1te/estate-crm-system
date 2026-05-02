import { useLoginForm } from '../model/useLoginForm'

export const LoginForm = () => {
  const {
    email,
    password,
    showPassword,
    setEmail,
    setPassword,
    handleSubmit,
    loading,
    error
  } = useLoginForm()

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input
        type={showPassword ? 'text' : 'password'}
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      {error && <p>{error}</p>}

      <button disabled={loading}>{loading ? 'Loading...' : 'Login'}</button>
    </form>
  )
}
