//
//  SettingsScreen.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//

import SwiftUI

struct SettingsScreen: View {
    var onClose: () -> Void                          // supplied by VC
    
    @State private var notifEnabled = false          // UI-only stub

    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SectionHeader("Personalization")
                    VStack(spacing: 20) {
                        row(icon: "calendar",   title: "Calendar") { }
                        row(icon: "bell",       title: "Notification") {
                            Toggle("", isOn: $notifEnabled)
                                .toggleStyle(.switch)
                        }
                        row(icon: "icloud",     title: "Sync") { }
                    }
                    
                    SectionHeader("Subscription")
                    row(icon: "creditcard", title: "Manage subscriptions") { }
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .toolbar {
            closeButton
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    /* ───────── row + header helpers ───────── */
    @ViewBuilder
    private func row<Accessory: View>(icon: String,
                                      title: String,
                                      @ViewBuilder accessory: () -> Accessory) -> some View
    {
        HStack {
            Image(systemName: icon).foregroundColor(.white)
            Text(title).foregroundColor(.white)
            Spacer()
            accessory()
        }
        .font(.system(size: 17, weight: .medium))
    }
    
    private func SectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.title2).fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.bottom, 4)
    }
    
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { onClose() } label: {
                Image(systemName: "xmark").foregroundColor(.white)
            }
        }
    }
}
