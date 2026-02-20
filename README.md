# Cartify

A simple, modern e-commerce mobile application built with **Flutter**.

Fetches products from **Fake Store API**, lets users browse items, view details, add products to cart, see total price, toggle between light & dark themes, and more.



## Features

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
    <td><b>Home (Dark)</b></td>
    <td><b>Home (Light)</b></td>
    <td><b>Product Detail</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/home_dark.jpeg?raw=true" width="220"></td>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/home_light.jpeg?raw=true" width="220"></td>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/detail.jpeg?raw=true" width="220"></td>
  </tr>
  <tr>
    <td><b>Cart</b></td>
    <td><b>Profile</b></td>
    <td><b>No Connection</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/cart_light.jpeg?raw=true" width="220"></td>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/profile_dark.jpeg?raw=true" width="220"></td>
    <td><img src="https://github.com/khanyousafzaideveloper/ProjectScreenShots/blob/main/cartify/no%20internet.jpeg?raw=true" width="220"></td>
  </tr>
</table>


## Tech Stack

- **Flutter**
- **Dart**
- **flutter_bloc** (Cubit)
- **dio** (for API calls)
- **shared_preferences** (theme persistence)
- **Fake Store API** — https://fakestoreapi.com
- Clean Architecture / Feature-first structure

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio
- Emulator or physical device

```bash

flutter --version

git clone https://github.com/khanyousafzaideveloper/cartify.git
cd cartify

flutter pub get

flutter run


