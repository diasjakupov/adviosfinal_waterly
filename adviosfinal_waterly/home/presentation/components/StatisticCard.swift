//
//  StatisticCard.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct StatisticCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.wSurface)
            .frame(height: 160)
            .overlay(
                VStack(alignment:.leading) {
                    Text("Statistics")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Spacer()
                    HStack {
                        StatBlock(label:"Tasks", value:"5")
                        StatBlock(label:"Meetings", value:"3")
                        StatBlock(label:"Hours", value:"4.5")
                    }
                }
                .padding(24)
            )
    }
    private struct StatBlock: View {
        var label:String; var value:String
        var body: some View {
            VStack {
                Text(value).font(.title3).bold().foregroundColor(.white)
                Text(label).font(.caption).foregroundColor(.wGreyLight)
            }
            .frame(maxWidth:.infinity)
        }
    }
}
