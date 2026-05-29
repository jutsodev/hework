# HeWork Messenger

Мессенджер нового поколения с поддержкой Bluetooth Mesh, E2E шифрованием и красивым дизайном в стиле Liquid Glass.

## 🚀 Функции

- **📧 Email верификация** — вход через электронную почту с кодом подтверждения
- **💬 Мессенджер** — обмен сообщениями в реальном времени
- **🔔 Push-уведомления** — мгновенные уведомления о новых сообщениях
- **📡 Bluetooth Mesh** — обмен сообщениями без интернета
- **🔐 E2E шифрование** — Curve25519 + AES-GCM
- **🎨 Кастомизация** — градиенты сообщений, акцентные цвета, обои
- **✨ Liquid Glass** — эффект жидкого стекла в навигации
- **📍 Рядом** — поиск пользователей поблизости
- **👤 QR-код** — быстрое добавление контактов

## 📱 Скриншоты

| Вход | Чаты | Настройки |
|------|-------|-----------|
| Email верификация | Список чатов | Кастомизация |

## 🏗 Архитектура

```
HeWork/
├── HeWork/
│   ├── HeWorkApp.swift          # Точка входа
│   ├── ContentView.swift         # Root view
│   ├── AppDelegate.swift         # Push notifications
│   ├── Models/
│   │   └── Models.swift          # Data models
│   ├── Views/
│   │   ├── Auth/
│   │   │   └── AuthFlowView.swift    # Email + Verification
│   │   ├── Chat/
│   │   │   ├── ChatListView.swift    # Chat list
│   │   │   ├── ChatDetailView.swift  # Messages
│   │   │   ├── NearbyView.swift      # Nearby users
│   │   │   └── ContactsView.swift    # Contacts
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift    # Settings
│   │   │   └── AppearanceView.swift  # Theme customization
│   │   ├── Profile/
│   │   │   └── ProfileView.swift     # Profile + QR
│   │   └── Components/
│   │       ├── LiquidGlassTabBar.swift  # Glass effect tab bar
│   │       └── SharedComponents.swift   # Shared UI
│   ├── Services/
│   │   ├── AuthService.swift        # Authentication
│   │   ├── ChatService.swift        # Chat operations
│   │   ├── NotificationService.swift # Push notifications
│   │   └── ThemeManager.swift       # Theme management
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift      # Auth state
│   │   └── ChatViewModel.swift      # Chat state
│   ├── Extensions/
│   │   └── Extensions.swift         # Color, Date, View extensions
│   └── Resources/
│       └── Assets.xcassets/
├── server/
│   ├── server.js               # Backend API
│   ├── package.json
│   └── .env.example
└── .github/
    └── workflows/
        └── build.yml           # CI/CD
```

## 🔧 Установка

### Требования

- Xcode 15.4+
- iOS 17.0+
- Swift 5.9+
- Node.js 20+ (для сервера)
- Firebase проект

### iOS Приложение

1. Клонируйте репозиторий:
```bash
git clone https://github.com/jutsodev/hework.git
cd hework/HeWork
```

2. Добавьте `GoogleService-Info.plist` от Firebase

3. Откройте `HeWork.xcodeproj` в Xcode

4. Выберите цель HeWork и запустите

### Сервер

1. Настройте переменные окружения:
```bash
cd server
cp .env.example .env
# Заполните .env файл
```

2. Установите зависимости:
```bash
npm install
```

3. Запустите сервер:
```bash
npm start
```

## 📧 Настройка Email (verification@hework.io)

1. Настройте MX-записи для `hework.io`
2. Создайте почтовый ящик `verification@hework.io`
3. Укажите SMTP данные в `.env`

Поддерживаемые провайдеры:
- Собственный SMTP сервер
- Google Workspace (с паролем приложения)
- Mailgun
- SendGrid

## 🔑 Firebase Настройка

1. Создайте проект в [Firebase Console](https://console.firebase.google.com)
2. Включите **Authentication** → **Email/Password**
3. Включите **Cloud Firestore**
4. Включите **Cloud Messaging**
5. Скачайте `GoogleService-Info.plist`
6. Скачайте Service Account Key для сервера

## 🛠 Технологии

| Компонент | Технология |
|-----------|------------|
| Клиент | Swift, SwiftUI |
| Бэкенд | Node.js, Express |
| База данных | Cloud Firestore |
| Аутентификация | Firebase Auth |
| Уведомления | Firebase Cloud Messaging |
| Email | Nodemailer |
| Шифрование | Curve25519, AES-GCM |
| Связь | Bluetooth Mesh |

## 📄 Лицензия

© 2024 HeWork. Все права защищены.
