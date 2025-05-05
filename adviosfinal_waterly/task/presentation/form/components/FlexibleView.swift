//
//  FlexibleView.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI


//struct FlexibleView<Content:View>: View {
//    let availableWidth: CGFloat
//    let spacing: CGFloat
//    let lineSpacing: CGFloat
//    let content: () -> Content
//    
//    @State private var sizes: [Int: CGSize] = [:]
//    
//    var body: some View {
//        let elements = Array(content().extractSubviews())
//        return VStack(alignment:.leading,spacing:lineSpacing){
//            ForEach(computeLines(elements),id:\.self){ line in
//                HStack(spacing:spacing){
//                    ForEach(line,id:\.self){ elem in elem }
//                }
//            }
//        }
//    }
//    // algorithm to wrap views
//    private func computeLines(_ views:[AnyView])->[[AnyView]]{
//        var lines:[[AnyView]]=[[]]
//        var currentWidth:CGFloat=0
//        for (index,view) in views.enumerated(){
//            let size = sizes[index, default:.zero]
//            if currentWidth+size.width+spacing>availableWidth{
//                lines.append([view]); currentWidth=size.width+spacing
//            }else{ lines[lines.count-1].append(view); currentWidth+=size.width+spacing }
//        }
//        return lines
//    }
//}
