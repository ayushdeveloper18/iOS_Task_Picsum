//
//  ImagesListView.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//


import SwiftUI

struct ImagesListView: View {
    @StateObject private var vm = ImagesListViewModel()
  
    
    @StateObject private var weatherVM = MapViewModel()
        @State private var selectedImage: PicsumImage?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading && vm.images.isEmpty {
                    ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !vm.images.isEmpty {
                    
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 12) {
//                            ForEach(vm.images) { img in
//                                if let s = img.download_url, let url = URL(string: s) {
//                                    ImageCellView(imageURL: url)
//                                        .frame(height: 180)
//                                        .onAppear { vm.loadNextPageIfNeeded(currentItem: img) }
//                                        .accessibilityElement(children: .combine)
//                                        .accessibilityLabel(img.author)
//                                } else {
//                                    Rectangle().frame(height: 180).foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding()
//                        if vm.isLoading {
//                            ProgressView().padding()
//                        }
//                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.images) { img in
                                if let s = img.download_url, let url = URL(string: s) {
                                    ImageCellView(imageURL: url)
                                        .frame(height: 300)        // bigger since it's full width
                                        .onAppear { vm.loadNextPageIfNeeded(currentItem: img) }
                                        // Tap Gesture here
                                        .onTapGesture {
                                            selectedImage = img
                                            weatherVM.select(image: img)
                                        }
                                        .accessibilityLabel(img.author)
                                } else {
                                    Rectangle()
                                        .frame(height: 300)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if vm.isLoading {
                            ProgressView().padding()
                        }
                    }

                } else if let err = vm.errorMessage {
                    VStack {
                        Text("Error").font(.headline)
                        Text(err).font(.footnote).foregroundColor(.secondary)
                        Button("Retry") { vm.loadInitial() }.padding(.top, 8)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No images").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Picsum Feed")
            
            .sheet(item: $selectedImage) { img in
                VStack(spacing: 12) {
                    Text(img.author)
                        .font(.headline)

                    if let s = img.download_url, let url = URL(string: s) {
                        ImageCellView(imageURL: url)
                            .frame(height: 250)
                            .cornerRadius(10)
                    }

                    if weatherVM.isLoadingWeather {
                        ProgressView("Loading weather…")
                    } else if let w = weatherVM.weather {
                        if let t = w.temperatureC {
                            Text("Temp: \(t, specifier: "%.1f") °C")
                        }
                        if let h = w.humidityPct {
                            Text("Humidity: \(Int(h))%")
                        }
                        if let v = w.windSpeed {
                            Text("Wind: \(v, specifier: "%.1f") m/s")
                        }
                        Text("Provider: \(w.provider)")
                    } else if let err = weatherVM.errorMessage {
                        Text("Error: \(err)").foregroundColor(.red)
                    } else {
                        Text("No weather data")
                    }

                    Spacer()

                    Button("Close") {
                        selectedImage = nil
                    }
                    .padding(.top)
                }
                .padding()
              
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)     
            }


            .onAppear { if vm.images.isEmpty { vm.loadInitial() } }
        }
    }
}

