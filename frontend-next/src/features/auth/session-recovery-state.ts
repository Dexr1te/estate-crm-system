export type SessionRecoveryReason = "recover" | "signout" | "forbidden" | "unavailable";

export function sessionRecoveryPresentation(reason: SessionRecoveryReason, terminal = false, completed = false) {
  if (reason === "recover" && terminal) {
    return { message: "Your session has expired. Sign in is required.", canRetry: false };
  }
  if (reason === "recover") {
    return completed
      ? { message: "Could not verify your session. Try again.", canRetry: true }
      : { message: "Checking your session.", canRetry: false };
  }
  const message = reason === "forbidden"
    ? "You do not have permission to view this page."
    : reason === "unavailable"
      ? "The service is temporarily unavailable."
      : "Your account is not active. Ending the session.";
  return {
    message,
    canRetry: reason === "signout" || reason === "unavailable",
  };
}
