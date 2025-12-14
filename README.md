# iOS_Task_Picsum

Image Feed
* Displays images fetched from Picsum API
* Infinite scrolling (paginated experience)
* Full-width image list (grid layout also implemented)
* Tap an image to view details and weather information
Map View
* Displays image locations on a map (Google Maps / MapKit)
* Each image is mapped to a deterministic coordinate
* Tap a marker to view image details and current weather
* Weather details are shown in a full-screen sheet
Weather
* Current weather fetched using Open-Meteo API
* Shows:
    * Temperature
    * Humidity
    * Wind speed
* No API key required for weather

🧱 Architecture
* SwiftUI for UI
* MVVM architecture
* Separate layers:
    * Models
    * ViewModels
    * Services
    * Views
* Networking handled using URLSession
* Simple, readable code (no async/await)

📦 Pagination
* Infinite scrolling implemented by loading more items when the user reaches the bottom
* Pagination logic is handled inside ImagesListViewModel
* New data is appended, not replaced

🗄 Image Caching
* In-memory caching using NSCache
* Disk caching to persist images across app launches
* Images are returned from cache before making network calls
* Improves performance and reduces network usage

🧪 Testing
Unit tests are added using XCTest.
Covered Test Cases
* API decoding
    * Validates decoding of Picsum API response
* Pagination logic
    * Ensures pagination loads images page by page
* Weather fetch logic (mocked)
    * Uses a mocked weather service
    * No real network calls during tests
How to run tests
* Open the project in Xcode
* Press ⌘ + U or run from the Test Navigator
