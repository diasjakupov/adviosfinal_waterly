//
//  Chip.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct Chip: View {
    var text:String
    var filled:Bool = false
    var tap:()->Void
    var body: some View {
        Button(action:tap){
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(filled ? .white : .wBlue)
                .padding(.horizontal,20).padding(.vertical,10)
                .background(
                    RoundedRectangle(cornerRadius:16)
                        .fill(filled ? Color.wBlue : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius:16)
                        .stroke(Color.wBlue,lineWidth:1)
                )
        }
    }
}
