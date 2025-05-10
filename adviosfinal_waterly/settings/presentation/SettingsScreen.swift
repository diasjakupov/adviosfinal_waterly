//
//  SettingsScreen.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//

import SwiftUI

struct SettingsScreen: View {
    var onClose: () -> Void
    @ObservedObject var vm: SettingsViewModel
    @State private var showGoogleError = false

    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SectionHeader("Personalization")
                    VStack(spacing: 20) {
                        row(icon: "calendar",   title: vm.isGoogleConnected ? "Connected: \(vm.googleUserEmail ?? "")" : "Connect with Google Calendar") {
                            Button(action: {
                                Task {
                                    if let vc = UIApplication.shared.topViewController() {
                                        if vm.isGoogleConnected {
                                            vm.disconnectGoogleCalendar()
                                        } else {
                                            await vm.connectGoogleCalendar(presentingViewController: vc)
                                        }
                                    }
                                }
                            }) {
                                Text(vm.isGoogleConnected ? "Disconnect" : "Connect")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.wBlue)
                                    .cornerRadius(8)
                            }
                            if vm.isGoogleConnected {
                                Button("Sync Tasks") {
                                    Task { await vm.syncAllTasksToGoogleCalendar() }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                        }
                        if !vm.syncStatus.isEmpty {
                            Text(vm.syncStatus)
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        }
                        row(icon: "bell",       title: "Notification") {
                            Toggle("", isOn: $vm.notifEnabled)
                                .toggleStyle(.switch)
                                .onChange(of: vm.notifEnabled) { isOn in
                                    vm.toggleNotifications(isOn)
                                }
                        }
                    }
                    
                    SectionHeader("Subscription")
                    row(icon: "creditcard", title: "Manage subscriptions") { }
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            if let error = vm.googleAuthError {
                ErrorBanner(message: error)
            } else if !vm.syncStatus.isEmpty && vm.syncStatus.lowercased().contains("fail") {
                ErrorBanner(message: vm.syncStatus)
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

// Helper to get the top UIViewController for presenting Google Sign-In
extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
