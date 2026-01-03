# StoreSence 🛍️

**Shop Easy and Go Easy.**

StoreSence is a modern "Scan & Go" mobile shopping application built with Flutter. It streamlines the retail experience by allowing customers to scan products, build a digital cart, and check out seamlessly—all from their smartphone. It also features a robust Store Manager Dashboard for inventory and sales management.

---

## 🚀 Key Features

### 🛒 For Customers
- **GPS Store Discovery**: Automatically detects and lists nearby registered stores based on your location.
- **Scan & Go**: Use the built-in barcode scanner to instantly add items to your cart.
- **Smart Cart**: Real-time total calculation with tax breakdown and carry bag options.
- **Digital Receipts**: View complete purchase history and transaction details.
- **Authentication**: Secure login/signup via email and OTP (Phone auth ready).

### 🏪 For Store Managers
- **Manager Dashboard**: Overview of today's sales, total products, and low stock alerts.
- **Inventory Management**: Add, edit, and delete products with ease.
- **Barcode Integration**: Register new products by simply scanning their barcodes.
- **Sales Tracking**: view recent transactions and sales history.
- **Store Management**: Register and manage multiple store locations.

---

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Backend & Database**: Supabase (PostgreSQL, Auth, Realtime)
- **State Management**: Provider
- **Location**: `geolocator` & `google_maps_flutter`
- **Scanning**: `mobile_scanner`
- **Storage**: `shared_preferences` (Local)
- **UI/UX**: Custom `AppTheme` with Google Fonts (Inter) and Material 3 design.

---

## 🏁 Getting Started

### Prerequisites
- **Flutter SDK**: v3.0.0 or higher
- **Dart SDK**: v3.0.0 or higher
- **Android Studio / VS Code** with Flutter extensions
- **Supabase Account**: For backend services

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Vijay-48/store-sence.git
    cd store-sence
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration:**
    Create a `.env` file (or update `lib/services/supabase_service.dart` directly if not using dotenv) with your Supabase credentials:
    ```dart
    const supabaseUrl = 'YOUR_SUPABASE_URL';
    const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
    ```

### 📱 Running the App

**For Android:**
```bash
flutter run
```

**For Windows:**
```bash
flutter run -d windows
```
*(Note: Ensure Developer Mode is enabled on Windows)*

---

## 🗂️ Project Structure

```
lib/
├── models/         # Data models (Product, Store, User, etc.)
├── presentation/   # UI Screens (organized by feature)
│   ├── authentication_screen/
│   ├── manager/    # Manager-specific screens (Dashboard, Add Product)
│   ├── shopping_cart/
│   └── ...
├── providers/      # State management (CartProvider, AuthProvider)
├── services/       # Backend logic (Supabase, Location)
├── theme/          # App design system (Colors, text styles)
└── widgets/        # Reusable UI components
```

---

## 🔐 Database Schema (Supabase)

The app requires the following tables in Supabase:
- `profiles`: User data and role (customer/manager).
- `stores`: Store locations and details.
- `products`: Inventory items linked to stores.
- `transactions`: Purchase records.
- `transaction_items`: Individual items within a transaction.

---

## 🤝 Contributing

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

*Built with ❤️ by the StoreSence Team*
