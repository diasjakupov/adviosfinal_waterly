//
//  ErrorBanner.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text(message)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                Spacer()
            }
            .padding(.horizontal)
            .background(Color.red.opacity(0.9))
            .cornerRadius(12)
            .padding()
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: message)
    }
}


struct ErrorBanner_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ErrorBanner(message: "This is an error message!")
        }
    }
}

