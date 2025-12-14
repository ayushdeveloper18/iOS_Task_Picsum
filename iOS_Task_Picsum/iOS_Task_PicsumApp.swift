import SwiftUI
//import GoogleMaps

@main
struct PicsumMapWeatherApp: App {
    
//    init() {
//           GMSServices.provideAPIKey("YOUR_GOOGLE_MAP_API_KEY")
//       }

    
    var body: some Scene {
        WindowGroup {
            TabView {
                ImagesListView()
                    .tabItem { Label("Feed", systemImage: "photo.on.rectangle") }
                MapScreenView()
                    .tabItem { Label("Map", systemImage: "map") }
            }
        }
    }
}
//#Preview {
//    PicsumMapWeatherApp()
//}
