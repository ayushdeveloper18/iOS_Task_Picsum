//
//  MapScreenView.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import SwiftUI

struct MapScreenView: View {
    // observe both VMs
    @StateObject private var vm = MapViewModel()
    @StateObject private var listVM = ImagesListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Map view observes MapViewModel
         //      GoogleMapView(vm: vm)
                MapKitMapView(vm: vm)
                    .edgesIgnoringSafeArea(.all)

                // Horizontal thumbnail scroller at bottom
                VStack {
                    Spacer()
                    if listVM.images.isEmpty && listVM.isLoading {
                        // show small loader while initial list loads
                        ProgressView().padding(12).background(.ultraThinMaterial).cornerRadius(10)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(listVM.images) { img in
                                    if let s = img.download_url, let url = URL(string: s) {
                                        ImageCellSmallView(imageURL: url)
                                            .frame(width: 120, height: 80)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                vm.select(image: img)
                                            }
                                            .accessibilityLabel(img.author)
                                    } else {
                                        Rectangle().frame(width: 120, height: 80).foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Map")
            // show sheet when a marker/image is selected
            .sheet(item: $vm.selectedImage) { img in
                // sheet content uses vm.weather / vm.isLoadingWeather
                VStack(spacing: 12) {
                    Text(img.author).font(.headline)
                    if vm.isLoadingWeather {
                        ProgressView("Loading weather...")
                    } else if let w = vm.weather {
                        if let t = w.temperatureC {
                            Text("Temp: \(String(format: "%.1f", t)) °C")

                        }
                        if let h = w.humidityPct {
                            Text("Humidity: \(Int(h))%")
                        }
                        if let v = w.windSpeed {
                            Text("Wind: \(String(format: "%.1f", v)) m/s")

                        }
                        Text("Provider: \(w.provider)")
                    } else if let err = vm.errorMessage {
                        Text("Error: \(err)").foregroundColor(.red)
                    } else {
                        Text("No weather data")
                    }

                    Spacer()
                    Button("Close") {
                        vm.selectedImage = nil
                    }
                    .padding(.top, 8)
                }
                .padding()
                .presentationDetents([.medium])
            }
            .onAppear {
                // load images list (if not loaded)
                if listVM.images.isEmpty {
                    listVM.loadInitial()
                }
                // connect images from listVM -> map vm immediately and whenever listVM.images changes
                vm.load(images: listVM.images)
            }
            // react to changes in listVM.images and update map vm
            .onReceive(listVM.$images) { imgs in
                vm.load(images: imgs)
            }
        }
    }
}

// small thumbnail cell for horizontal scroller (uses the same ImageLoader)
struct ImageCellSmallView: View {
    let imageURL: URL
    @StateObject private var loader = ImageLoader()

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color(uiColor: .systemGray5)).cornerRadius(6)
            if let ui = loader.image {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(6)
                    .clipped()
            } else if loader.isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { loader.load(url: imageURL) }
        .onDisappear { loader.cancel() }
    }
}
