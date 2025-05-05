//
//  LabeledBox.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct LabeledBox<Content:View>: View {
    var label:String
    @ViewBuilder var content: Content
    init(_ label:String,@ViewBuilder content:()->Content){
        self.label=label; self.content=content()
    }
    var body: some View {
        VStack(spacing:4){
            Text(label).font(.caption)
                .foregroundColor(.wGreyText)
                .frame(maxWidth:.infinity,alignment:.leading)
            content
        }
        .padding(12)
        .background(Color.wSurface)
        .cornerRadius(12)
    }
}
