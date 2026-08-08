<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=0,2,3,4,6,8&height=5&section=header" width="100%" />
</p>

<div align="center">
  <h1>📱 SaveRoom Scanner App</h1>
  <p><strong>Flutter mobile scanner & collection UI</strong><br/>card lookup · pricing · inventory · seller workflows</p>
</div>

<p align="center">
  <a href="#">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"></a>
  <a href="#">
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"></a>
  <a href="#">
    <img src="https://img.shields.io/badge/API-SaveRoom%20v12.2.0-22498e?style=for-the-badge"></a>
  <a href="#">
    <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white"></a>
  <a href="#">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge"></a>
</p>

---

## 📌 Overview

SaveRoom Scanner App is a **Flutter mobile frontend** that consumes the [SaveRoom Pokémon Database API](https://github.com/MatthewRobertLotts/SaveRoom-Pokemon-Database-API). It provides visual scanner, search, collection, and seller workflow tools for Pokémon TCG.

> 💡 **Design principle:** The app consumes the API — it does not ship the database brain inside the app.

---

## ✨ Features

| Feature | Status |
|---------|--------|
| 🔍 Card search & autocomplete | ✅ |
| 🖼️ Detail view with images | ✅ |
| 💰 Pricing display (Market Price) | ✅ |
| 📋 Collection management | In progress |
| 📷 Camera scanner | Planned |
| 📦 Inventory workflows | Planned |

---

## 🚀 Getting Started

```bash
# Prerequisites: Flutter SDK, Android SDK
git clone https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App.git
cd SaveRoom-Scanner-App

# Run in fixture mode (default)
flutter run

# Run against local API
flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              SaveRoom Scanner App                     │
├─────────────────────────────────────────────────────┤
│  Screens: Search · Detail · Scanner · Collection      │
│  Widgets: CardImagePanel · SearchBar · PriceDisplay   │
│  Services: APIClient · FixtureProvider                │
│  Models: Card · Set · Pricing · Inventory             │
└────────────────────────┬────────────────────────────┘
                         │ HTTP/REST
                         ▼
┌─────────────────────────────────────────────────────┐
│          SaveRoom Pokémon DB API (v12.2.0)            │
└─────────────────────────────────────────────────────┘
```

---

## 🔗 Related

| Project | Purpose |
|---------|---------|
| **This repo** | 👈 Flutter scanner & collection frontend |
| [`SaveRoom-Pokemon-Database-API`](https://github.com/MatthewRobertLotts/SaveRoom-Pokemon-Database-API) | Backend brain / API / data platform |

---

## 📄 License

Copyright © 2026 Matthew Lotts. Licensed under the **Apache License, Version 2.0**. See [`LICENSE`](LICENSE) for details.

---

<p align="center">
  <a href="https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App/stargazers"><img src="https://img.shields.io/github/stars/MatthewRobertLotts/SaveRoom-Scanner-App?style=social&label=Stars"></a>
  <a href="https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App/network"><img src="https://img.shields.io/github/forks/MatthewRobertLotts/SaveRoom-Scanner-App?style=social&label=Forks"></a>
</p>