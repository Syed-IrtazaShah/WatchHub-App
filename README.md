# ⌚ WatchHub - Premium Watch E-Commerce & Admin Ecosystem

<p align="center">
  <img src="watchhub/assets/images/logo.png" alt="WatchHub Logo" width="160" error="true"/>
</p>

<p align="center">
  <b>A complete, modern E-Commerce solution for luxury and luxury-inspired timepieces built with Flutter & Supabase backend.</b>
</p>

<p align="center">
  <a href="#-projects-overview"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge"/></a>
  <a href="#-backend--database"><img src="https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase Badge"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge"/></a>
  <a href="#-licensing"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License Badge"/></a>
</p>

---

## 📱 Project Overview

**WatchHub** is a dual-application E-Commerce ecosystem consisting of a feature-rich mobile app for watch enthusiasts and a powerful admin control dashboard for business operations.

```
Watch-Hub-flutterApp/
├── 📱 watchhub/      # Customer Mobile Application (iOS & Android)
└── 💻 adminapp/      # Administrator Dashboard & Management App
```

---

## ✨ Features

### 🛒 1. Customer Application (`watchhub`)
- 🔒 **User Authentication**: Secure Login, Sign-up, and session persistence via Supabase Auth & Secure Storage.
- 🏠 **Home & Discovery**: Dynamic hero banners, top featured watch collections, category filtering, and brand discovery.
- ⌚ **Interactive Product Catalog**: Detailed watch specifications, multi-image view, ratings, customer reviews, and stock availability.
- 🛍️ **Cart & Checkout**: Real-time quantity calculation, price breakdowns, coupon codes, and address selection.
- ❤️ **Wishlist**: Quick-save favorite watches for later purchase.
- 📦 **Order Management**: Real-time order placement, status tracking (Processing, Shipped, Delivered), and receipt history.
- 👤 **Profile & Addresses**: Manage user profiles, multiple shipping addresses, and support tickets.
- 💬 **Customer Support & Feedback**: In-app feedback submission and direct support channel.

### 🖥️ 2. Admin Dashboard (`adminapp`)
- 📊 **Executive Dashboard**: Real-time analytics overview (Total Revenue, Orders Count, Product Inventory, and Active Users).
- 🏷️ **Brand & Product Management**: Add, update, or remove luxury watch brands and catalog items with image uploads.
- 📑 **Order Fulfillment**: Track all incoming customer orders, manage shipping pipelines, and update order statuses.
- 👥 **User Management**: Monitor user registrations, view customer metrics, and manage user permissions.
- ⭐ **Reviews & Moderation**: Review customer ratings, feedback, and support inquiries.
- 💬 **Live Support Chat**: Chat interface for customer inquiry resolution.

---

## 🛠️ Tech Stack & Architecture

- **Frontend Framework**: [Flutter](https://flutter.dev) (Dart)
- **Backend & Database**: [Supabase](https://supabase.com) (PostgreSQL, Supabase Auth, Supabase Storage)
- **State Management**: Provider / GetX Architecture
- **Local Storage**: `flutter_secure_storage`, `shared_preferences`
- **UI Components**: Google Fonts, Lottie Animations, Carousel Slider, Photo View

---

## 📂 Repository Structure

```gcode
Watch-Hub-flutterApp/
│
├── adminapp/                    # Admin Dashboard Application
│   ├── lib/
│   │   ├── controllers/         # Admin business logic & state management
│   │   ├── models/              # Data models (Order, Product, Brand, User)
│   │   ├── utils/               # App theme, constants, & route definitions
│   │   ├── views/               # Admin screens (Dashboard, Products, Orders, Users, Reviews)
│   │   └── widget/              # Reusable admin UI widgets (Sidebar, Data Tables, Charts)
│   └── pubspec.yaml
│
├── watchhub/                    # Customer Mobile Application
│   ├── assets/                  # App images and Lottie animations
│   ├── lib/
│   │   ├── controllers/         # Client controllers & state management
│   │   ├── models/              # Product, Cart, Order, Address, & Review models
│   │   ├── services/            # Supabase API services (Auth, Product, Order, Feedback)
│   │   ├── utils/               # Theme colors, text styles, constants & navigation
│   │   └── views/               # Customer screens (Auth, Home, Catalog, Cart, Checkout, Profile)
│   └── pubspec.yaml
│
├── .gitignore                   # Workspace root Git ignore configuration
└── README.md                    # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10+ recommended)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (for mobile emulators) or VS Code
- A [Supabase](https://supabase.com) project setup with database tables for products, orders, brands, and users.

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Syed-IrtazaShah/WatchHub-App.git
   cd WatchHub-App
   ```

2. **Run Customer App (`watchhub`):**
   ```bash
   cd watchhub
   flutter pub get
   flutter run
   ```

3. **Run Admin App (`adminapp`):**
   ```bash
   cd ../adminapp
   flutter pub get
   flutter run
   ```

---

## ⚙️ Supabase Configuration

Set up your Supabase project credentials in your environment / constants file (`lib/utils/appconstant.dart` or service config):

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check out the [Issues](https://github.com/Syed-IrtazaShah/WatchHub-App/issues) page.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more details.
