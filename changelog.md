# Changelog

## 2026-10-12

### PH00 — локальная основа Next.js завершена

Локальная основа Next.js и тестовый harness завершены: 63 локальных unit/component/API-теста и 6/6 Playwright-проверок в Chrome 154. Проверки типов, lint и API-only Next build прошли. Сохранён статический архив старого Vite frontend для отката. Формальный DoD PH00 не закрыт: реальные Spring/PostgreSQL fixtures и production API/security proof по B02 остаются открытыми; production host/domain, часовой пояс, invite/reset destinations, map provider/auth image и G01/G02 enforcement остаются release gates. Покрытие пользовательских leaf pages в B07 остаётся частичным. См. [статус PH00](docs/web-nextjs-implementation/PH00-status.md) и [архив старого фронтенда для отката](artifacts/ph00/review/b10/legacy-frontend-vite-static-local-api-b64f25b.tar.gz).
