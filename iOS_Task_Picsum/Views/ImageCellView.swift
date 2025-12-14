//
//  ImageCellView.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import SwiftUI

struct ImageCellView: View {
    let imageURL: URL
    @StateObject private var loader = ImageLoader()

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color(uiColor: .systemGray5)).cornerRadius(8)
            if let ui = loader.image {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(8)
                    .accessibilityHidden(true)
            } else if loader.isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
        .clipped()
        .onAppear { loader.load(url: imageURL) }
        .onDisappear { loader.cancel() }
    }
}

//#Preview {
//    ImageCellView(imageURL: URL(string: "") ?? "", loader: <#T##arg#>)
//}
