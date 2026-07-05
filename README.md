# 🏢 Real Estate CRM System

> A full-stack CRM platform designed for real estate agencies to manage clients, properties, and sales pipelines efficiently.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg)
![Stack](https://img.shields.io/badge/stack-React%20%7C%20Java%20%7C%20Flutter-blueviolet)

---

## 📌 Problem Statement

Real estate agencies struggle to manage large volumes of clients, property listings, and deal pipelines using scattered tools like spreadsheets and emails. This CRM centralizes everything into one professional platform.

---

## ✨ Features

- 👥 Manage buyers and sellers in one place
- 🏠 Track property listings with full details
- 📊 Monitor deal stages — Lead → Negotiation → Closed
- 📅 Schedule meetings and set reminders
- 📁 Store and manage deal documents
- 📈 Analyze sales performance with dashboards

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React, TypeScript, Vite |
| Backend | Java, Spring Boot, Maven |
| Mobile | Flutter (Dart) |
| Database | PostgreSQL |

---

## ⚙️ Installation

### Prerequisites

- Java 17+
- Node.js 18+ and npm
- Flutter SDK 3.x (FVM supported — see `mobile/.fvmrc`)
- Docker & Docker Compose (for backend + database)

### Backend

```bash
cd backend
docker-compose up --build
```

API runs on `http://localhost:8080`. PostgreSQL is exposed on port `5433`.

### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

See [mobile/README.md](mobile/README.md) for platform-specific notes.

---

## 🚀 Usage

1. Register or log in as a real estate agent
2. Add clients and property listings
3. Track deals through the Lead → Negotiation → Closed pipeline
4. Schedule meetings and set reminders
5. Generate performance reports from the dashboard

---

## 📁 Project Structure

```
estate-crm-system/
├── backend/        # Spring Boot REST API
├── frontend/       # React web application
├── mobile/         # Flutter mobile app
├── docs/           # Documentation
└── AGENTS.md       # AI agent instructions (optional)
```

---

## 👥 Team

| Name | ID |
|---|---|
| Assan Sultan | 230103325 |
| Koibagar Nurserik | 230103145 |
| Amangeldi Dauirkhan | 230103386 |
| Muratbek Mukamet | 230103265 |

---

## 📄 License

This project is licensed under the MIT License.
