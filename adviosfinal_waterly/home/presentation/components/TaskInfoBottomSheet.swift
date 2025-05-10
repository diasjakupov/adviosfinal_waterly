//
//  TaskInfoBottomSheet.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//


import SwiftUI

struct TaskInfoBottomSheet: View, Identifiable {
    var id: UUID { task.id }
    
    // IN
    var task: TaskUI
    var onDismiss: () -> Void
    var onChangeStatus: (TaskStatus) -> Void        // ← call back to VM
    var onEdit: ((TaskUI) -> Void)? = nil
    var onDelete: ((TaskUI) -> Void)? = nil
    var error: String? = nil
    
    // LOCAL
    @State private var status: TaskStatus
    @State private var showDeleteConfirm = false
    
    init(task: TaskUI,
         onDismiss: @escaping () -> Void,
         onChangeStatus: @escaping (TaskStatus) -> Void,
         onEdit: ((TaskUI) -> Void)? = nil,
         onDelete: ((TaskUI) -> Void)? = nil,
         error: String? = nil) {
        self.task = task
        self.onDismiss = onDismiss
        self.onChangeStatus = onChangeStatus
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.error = error
        _status = State(initialValue: task.status)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            /** grab handle */
            Capsule().fill(Color.white.opacity(0.4))
                .frame(width: 120, height: 4).padding(.top, 8)
            
            /** Title */
            Text(task.title)
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            /** Times */
            HStack(spacing: 40) {
                timeBlock(label: "Start", value: task.start)
                timeBlock(label: "End",   value: task.end)
            }
            
            /** Duration */
            Text("Duration: \(task.duration)")
                .foregroundColor(.white.opacity(0.7))
            
            /** Status picker */
            Picker("Status", selection: $status) {
                ForEach(TaskStatus.allCases, id:\.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: status) { onChangeStatus($0) }
            
            HStack(spacing: 16) {
                Button("Edit") {
                    onEdit?(task)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth:.infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
                Button("Delete") {
                    showDeleteConfirm = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth:.infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
            
            Spacer()
            
            Button("Close") { onDismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth:.infinity)
                .padding()
                .background(Color.wBlue)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 24)
            if let error = error {
                ErrorBanner(message: error)
            }
        }
        .padding(.horizontal)
        .background(Color.wSurface)
        .ignoresSafeArea(.container, edges: .bottom)
        .alert(isPresented: $showDeleteConfirm) {
            Alert(
                title: Text("Delete Task?"),
                message: Text("Are you sure you want to delete this task? This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete?(task)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    /* small helper */
    @ViewBuilder
    private func timeBlock(label: String, value: String) -> some View {
        VStack {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.7))
            Text(value).font(.headline).foregroundColor(.white)
        }
    }
}
