# Cartify

A simple, modern e-commerce mobile application built with **Flutter**.

Fetches products from **Fake Store API**, lets users browse items, view details, add products to cart, see total price, toggle between light & dark themes, and more.

<p align="center">
  <img src="screenshots/home_light.png" width="30%" alt="Home Screen Light">
  <img src="screenshots/home_dark.png" width="30%" alt="Home Screen Dark">
  <img src="screenshots/product_detail.png" width="30%" alt="Product Detail">
</p>

## ✨ Features

- Fetch products from Fake Store API
- Clean product list with grid layout
- Detailed product view
- Cart screen with real-time total price calculation
- Profile screen
- Light / Dark theme toggle (persisted locally)
- Logout button
- State management with **BLoC (Cubit)**
- Proper loading, success & error states
- Clean Architecture inspired folder structure

## Screenshots

<table>
  <tr>
    <td><b>Home (Light)</b></td>
    <td><b>Home (Dark)</b></td>
    <td><b>Product Detail</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/home_light.png" width="220"></td>
    <td><img src="screenshots/home_dark.png" width="220"></td>
    <td><img src="screenshots/product_detail.png" width="220"></td>
  </tr>
  <tr>
    <td><b>Cart</b></td>
    <td><b>Profile</b></td>
    <td><b>Empty Cart</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/cart.png" width="220"></td>
    <td><img src="screenshots/profile.png" width="220"></td>
    <td><img src="screenshots/cart_empty.png" width="220"></td>
  </tr>
</table>


## Tech Stack

- **Flutter** (3.x)
- **Dart**
- **flutter_bloc** (Cubit)
- **http** / **dio** (for API calls)
- **shared_preferences** (theme persistence)
- **Fake Store API** — https://fakestoreapi.com
- Clean Architecture / Feature-first structure

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+ recommended)
- Dart SDK
- Android Studio
- Emulator or physical device

```bash

flutter --version

git clone https://github.com/khanyousafzaideveloper/cartify.git
cd cartify

flutter pub get

flutter run


