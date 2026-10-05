# EmpManage — Modern Employee Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.47.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Hosting%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Web](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-4CAF50)](https://employee-management-syst-100e1.web.app)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A full-stack, enterprise-grade **Employee Management System** built with **Flutter** and **Firebase**. Designed with modern Material 3 aesthetics, role-based access control (RBAC), real-time Cloud Firestore synchronization, attendance tracking, and dynamic analytics.

---

## 🌐 Live Deployment

* **Live Web App**: [https://employee-management-syst-100e1.web.app](https://employee-management-syst-100e1.web.app)
* **Alternative Domain**: [https://employee-management-syst-100e1.firebaseapp.com](https://employee-management-syst-100e1.firebaseapp.com)
* **Firebase Console**: [https://console.firebase.google.com/project/employee-management-syst-100e1/overview](https://console.firebase.google.com/project/employee-management-syst-100e1/overview)

---

## 🔑 Demo Access (Instant Access)

The application provides instant 1-click demo logins right on the login screen:

| Role | Email | Password | Access Level |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@empmanage.com` | `Admin@123` | Full administrative control (CRUD, stats, departments, attendance records) |
| **Employee** | `rahul@empmanage.com` | `Emp@12345` | Personal portal (Check-in/out, attendance log, profile details) |

*You can either click the **⚡ Login** button next to each account on the login card, or enter the credentials manually.*

---

## ✨ Features & Capabilities

### 👑 1. Admin Portal
* **Executive Dashboard**:
  * Real-time metrics: Total Employees, Active Count, Departments, Today's Attendance Rate.
  * Interactive breakdown charts for department distributions.
  * Recent activity feed and quick action shortcuts.
* **Employee Management (CRUD)**:
  * **Add Employee**: Multi-field form validation (name, email, phone, designation, department, joining date, salary, employment type, gender, address).
  * **Edit Employee**: Live updates with instant data propagation.
  * **Employee Directory**: Instant search by name/ID, department filter chips, and active/inactive status toggle.
  * **Employee Profile View**: Sliver-based detail view highlighting contact details, employment history, and department affiliations.
* **Department Control**:
  * Create, edit, and organize departments (Engineering, HR, Marketing, Finance, etc.).
  * Assign department managers and track automatic employee headcount.
* **Attendance Oversight**:
  * View real-time organizational attendance logs with timestamps and duration calculations.

### 👤 2. Employee Portal
* **Daily Attendance Clock**:
  * One-tap **Check-In** and **Check-Out** with exact timestamp capture.
  * Real-time work duration tracker and daily status badges.
* **Attendance History**:
  * Complete monthly log showing attendance dates, check-in/out times, and remarks.
* **Profile Management**:
  * View and update personal profile details, phone number, and address.

### 🎨 3. UI/UX & Design System
* **Material 3 Design**: Custom color palette featuring Deep Navy (`#1E3A8A`), Royal Blue (`#2563EB`), vibrant status colors, and neutral surfaces.
* **Responsive Layout**: Adaptive split-panel layout on desktop/tablet with collapsible sidebars, and fluid bottom-navigation on mobile screens.
* **Micro-interactions**: Smooth transitions, loading spinners, form validation banners, and floating snackbars.

---

## 🏗️ Architecture & Tech Stack

```
Employee-Management-System/
├── android/                  # Android native project configurations
├── web/                      # Web entry point, manifest, index.html
├── lib/
│   ├── main.dart             # App initialization & route registration
│   ├── firebase_options.dart # Firebase platform configurations
│   ├── core/
│   │   ├── constants/        # AppColors, AppStrings, AppConstants
│   │   ├── theme/            # Material 3 light/dark AppTheme
│   │   ├── utils/            # Form validators & formatting helpers
│   │   └── widgets/          # CustomButton, CustomTextField, StatsCard
│   ├── models/               # UserModel, EmployeeModel, DepartmentModel, AttendanceModel
│   ├── routes/               # Named route definitions & transitions
│   ├── screens/
│   │   ├── auth/             # LoginScreen with 1-click demo access
│   │   ├── splash/           # Animated splash screen with session recovery
│   │   ├── admin/            # AdminDashboard, Employee CRUD, Departments
│   │   └── employee/         # EmployeeDashboard, Attendance Tab, Profile
│   └── services/             # AuthService, EmployeeService, DepartmentService,
│                             # AttendanceService, StorageService, SeedService
├── firestore.rules           # Cloud Firestore security rules
├── storage.rules             # Firebase Storage security rules
├── firebase.json             # Firebase Hosting & CLI configuration
└── pubspec.yaml              # Flutter dependencies and assets
```

### Technology Highlights
* **Framework**: Flutter Web & Mobile (`Channel stable, 3.47.0`)
* **State & Networking**: Dart Streams & Cloud Firestore real-time snapshots
* **Typography**: Google Fonts (`Inter`)
* **Icons**: Cupertino Icons & Material Symbols
* **Backend Services**:
  * **Firebase Authentication**: Email/Password authentication & demo session fallback
  * **Cloud Firestore**: NoSQL real-time document database
  * **Firebase Hosting**: High-speed CDN global delivery

---

## 🚀 Getting Started Locally

### Prerequisites
1. **Flutter SDK** (`>= 3.3.0`): [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yenibaraanoopjoel-sys/Employee-Management-System.git
   cd Employee-Management-System
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web)**:
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android**:
   ```bash
   flutter run -d android
   ```

---

## 📦 Building & Deploying to Firebase

### 1. Build Production Web Bundle
```bash
flutter build web --release
```

### 2. Deploy to Firebase Hosting & Firestore
```bash
# Deploy hosting and database rules
firebase deploy --only hosting,firestore:rules
```

---

## 🔒 Security Configuration

Cloud Firestore security rules are maintained in `firestore.rules`:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Configured for demo & authenticated access
    }
  }
}
```

---

## 📄 License
This project is open-source and licensed under the [MIT License](LICENSE).
