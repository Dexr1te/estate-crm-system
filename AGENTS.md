# AGENTS.md — Repository agent instructions

Purpose: Give concise, actionable rules and shortcuts so AI coding agents (and humans) can be productive in this monorepo.

- **Scope:** This repository is a monorepo with three main workspaces: `backend/` (Java/Maven), `frontend/` (TypeScript/Vite), and `mobile/` (Flutter). Agents should detect the area from file paths and run area-specific commands below.

- **Quick commands:**
  - **Backend build/test:** `cd backend && ./mvnw package` / `cd backend && ./mvnw test`
  - **Frontend dev/build/test:** `cd frontend && npm install && npm run dev` / `cd frontend && npm run build` / `cd frontend && npm test`
  - **Mobile (Flutter):** `cd mobile && flutter pub get` / `cd mobile && flutter run` / `cd mobile && flutter test`

- **Key files & locations:**
  - **Backend:** [backend/pom.xml](backend/pom.xml#L1) — Maven project and build config.
  - **Frontend:** [frontend/package.json](frontend/package.json#L1) and [frontend/src/](frontend/src/) — app entry and components.
  - **Mobile:** [mobile/lib/](mobile/lib/) — Flutter app sources and [mobile/pubspec.yaml](mobile/pubspec.yaml#L1).

- **Behavior rules (concise):**
  - **Minimal edits:** When asked to modify code near the user's cursor, produce the smallest focused patch that fixes the issue. Use `apply_patch` with limited context (3 lines above/below) and avoid sweeping refactors unless explicitly requested.
  - **Verify locally:** After code edits, run the targeted build/test command for the affected area. Report failures and propose next steps.
  - **Link not duplicate:** When documenting conventions, link to existing docs in `docs/`, `README.md`, or specific files above rather than copying long fragments.
  - **Use the todo list:** For multi-step changes, use the repository TODO tracker (the agent's `manage_todo_list`) to list and update steps.
  - **Ask when ambiguous:** If a requested change impacts multiple areas or is ambiguous with respect to UX or data, ask a clarifying question before applying the patch.

- **Cursor-specific guidance (you asked for `cursor` focus):**
  - **Respect cursor locality:** Prefer edits that are anchored to the cursor position. If the user places the cursor inside a function/file, treat that as the primary scope.
  - **Show the diff & intent:** Before applying larger changes, present a short diff snippet and one-line rationale. Wait for confirmation if the change touches >3 files or >200 LOC.
  - **Preserve context:** Keep formatting and surrounding code intact; do not reformat entire files.

- **PR / Commit guidance:**
  - Use small commits with descriptive messages. For agent-made patches, include `chore(agent): ...` or `fix(agent): ...` prefix and reference relevant issue/REQ if available.

- **Safety & limits:**
  - Do not run destructive commands (docker-compose down --volumes, rm -rf) without explicit user consent.

If you'd like, I can also add a `.github/copilot-instructions.md` with a shortened variant of these points targeted specifically at GitHub Copilot. Next suggested customization: add language-specific skills for frontend and mobile linting/formatting.
