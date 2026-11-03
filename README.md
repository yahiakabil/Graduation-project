# Shiftly — Integrated Workforce Attendance & Payroll System

> **Graduation Project** by Yahia Kabil  
> An enterprise-grade, full-stack workforce operations management platform featuring real-time GPS geofenced attendance, biometric verification, graduated deduction policy engine, and daily salary accrual disbursement.

---

## 🏗️ Architecture & Technology Stack

| Layer | Technology | Key Capabilities |
| :--- | :--- | :--- |
| **Frontend** | **Flutter 3.x (Dart)** | Cross-platform client (Web, Android APK, Windows Desktop), BLoC/Cubit state management, dual Nordic Pro Light & Cyber Neon Dark themes. |
| **Backend** | **ASP.NET Core 9 (.NET 9 Web API)** | RESTful API, JWT Bearer authentication, Entity Framework Core, role-based authorization (Admin / HR vs. Manager vs. Employee). |
| **Database** | **Microsoft SQL Server (`AttendanceDb`)** | Relational schema with 100 seeded employees across 6 corporate teams, historical attendance, payroll archives, and immutable audit logs. |

---

## 🌟 Key Features

1. **GPS Geofence Attendance Engine:**
   - Real-time mobile check-in/out with distance verification against branch office coordinates.
   - Dynamic GPS recalibration: HR Administrators can re-calibrate office coordinates and geofence radius live directly from the app.
   - Anti-spoofing and mock location detection at the backend API layer.

2. **Daily Accrual & Salary Disbursement System:**
   - Real-time day-by-day salary accrual calculation with automatic daily disbursement lockouts (single-day payout controls).
   - Permanent SQL Server audit logging (`DisbursementLogs`) tracking every disbursement transaction.

3. **Multi-Tier Lateness Ladder & Policy Engine:**
   - Configurable grace periods and graduated deduction tiers (Grace 0-15m, Tier 1: 16-60m, Tier 2: 61-120m, Tier 3: 121-240m, Tier 4: >240m unexcused absence).
   - Automatic overtime calculation with configurable multiplier rates.

4. **HR-Governed Authorization Hierarchy:**
   - HR is the sole fiscal authority: both employee and manager requests feed into the HR approval pipeline.
   - Dynamic notification badges and unread counter badges on navigation and action bars.

5. **Dual-Theme Design System:**
   - High-contrast **Cyber Neon** dark appearance and clean **Nordic Pro** light appearance with instant frame-level switching.

---

## 📁 Repository Structure

```text
├── integrated_workforce_app/    # Flutter Client (Web, Android, Desktop)
│   ├── lib/
│   │   ├── core/               # Theme tokens, extensions, app config
│   │   ├── data/               # Models, API clients, repositories
│   │   ├── logic/              # BLoC / Cubits (Auth, Attendance, Payroll, etc.)
│   │   └── presentation/       # UI screens & modular widgets
│   ├── web/                    # Responsive web shell with mobile viewport
│   └── pubspec.yaml
│
├── WorkforceApi/               # ASP.NET Core 9 Web API
│   ├── Controllers/            # CoreControllers, ManagementControllers
│   ├── Services/               # BusinessServices, AttendanceService, PayrollService
│   ├── Data/                   # DbContext, DatabaseSeeder (100 users, 6 depts)
│   ├── DTOs/                   # Data transfer records
│   └── Program.cs
│
└── README.md
```

---

## 🚀 Getting Started

### 1. Backend Setup (.NET 9 + SQL Server)
```bash
cd WorkforceApi
dotnet restore
dotnet build
dotnet run
```
* The API will listen on `http://0.0.0.0:5050` with Swagger UI available at `/`.
* Automatically seeds the database on initial startup.

### 2. Frontend Setup (Flutter)
```bash
cd integrated_workforce_app
flutter pub get
flutter run -d edge    # Run on Web (Edge / Chrome)
# OR
flutter build apk      # Build Android APK
# OR
flutter build windows  # Build Windows Desktop (.exe)
```

---

## 👤 Author
* **Yahia Kabil**
* Email: [yehiakabkl123@gmail.com](mailto:yehiakabkl123@gmail.com)
