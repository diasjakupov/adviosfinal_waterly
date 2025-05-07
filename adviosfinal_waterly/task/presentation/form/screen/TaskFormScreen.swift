//
//  TaskFormScreen.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//


import SwiftUI

struct TaskFormScreen: View {
    // Callback for closing the form
    var onClose: () -> Void
    
    // View-model injected from UIKit
    @EnvironmentObject var vm: TaskFormViewModel
    
    // Sheet / dialog flags
    @State private var showDatePicker  = false
    @State private var showStartPicker = false
    @State private var showEndPicker   = false
    @State private var showRepeatSheet = false
    @State private var showAddCatDlg   = false
    @State private var newCatName      = ""
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    dateTimeSection
                    categoriesSection
                    notesSection
                    repeatSection
                    Spacer(minLength: 40)
                    saveButton
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            
            if let err = vm.error {
                errorToast(err)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { onClose() } label: {
                    Image(systemName: "xmark").foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        
        /* sheets / dialogs */
        .sheet(isPresented: $showDatePicker)  { datePickerSheet }
        .sheet(isPresented: $showStartPicker) { timePickerSheet($vm.start) }
        .sheet(isPresented: $showEndPicker)   { timePickerSheet($vm.end) }
        .confirmationDialog("Repeat",
                            isPresented: $showRepeatSheet,
                            titleVisibility: .visible) {
            ForEach(RepeatRule.allCases, id: \.self) { r in
                Button(r.rawValue) { vm.repeatRule = r }
            }
        }
        .alert("New category", isPresented: $showAddCatDlg) {
            TextField("Name", text: $newCatName)
            Button("Add") {
                let n = newCatName.trimmingCharacters(in: .whitespaces)
                if !n.isEmpty { vm.addCat(n) }
                newCatName = ""
            }
            Button("Cancel", role: .cancel) { newCatName = "" }
        }
    }
    
    // MARK: sections -------------------------------------------------------
    
    private var titleSection: some View {
        LabeledBox("Title") {
            HStack {
                TextField("Title", text: $vm.title)
                    .foregroundColor(.white)
                if !vm.title.isEmpty {
                    Button { vm.title = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.wGreyText)
                    }
                }
            }
        }
    }
    
    private var dateTimeSection: some View {
        HStack(spacing: 12) {
            Chip(text: dateLabel(vm.date), filled: true) { showDatePicker = true }
            Chip(text: timeLabel(vm.start)) { showStartPicker = true }
            Chip(text: timeLabel(vm.end))   { showEndPicker   = true }
        }
    }
    
    private var categoriesSection: some View {
        FlowLayout(spacing: 12, lineSpacing: 12) {
            ForEach(vm.categories, id: \.self) { cat in
                let on = vm.selected == cat
                Chip(text: cat, filled: on) {
                    vm.selected = on ? nil : cat
                }
            }
            Chip(text: "+") { showAddCatDlg = true }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").foregroundColor(.white)
            ZStack(alignment: .topLeading) {
                if vm.notes.isEmpty {
                    Text("Value")
                        .foregroundColor(.wGreyText)
                        .padding(8)
                }
                TextEditor(text: $vm.notes)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .padding(8)
            }
            .frame(height: 120)
            .background(Color.wSurface)
            .cornerRadius(12)
        }
    }
    
    private var repeatSection: some View {
        HStack {
            Text("Repeat").foregroundColor(.white)
            Spacer()
            Chip(text: vm.repeatRule.rawValue) {
                showRepeatSheet = true
            }
        }
    }
    
    private var saveButton: some View {
        Button { vm.save() } label: {
            Text("SAVE")
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.title.isEmpty ? Color.gray : Color.wBlue)
                .cornerRadius(12)
        }
        .disabled(vm.title.isEmpty)
    }
    
    // MARK: helper views ---------------------------------------------------
    
    private func errorToast(_ msg: String) -> some View {
        Text(msg)
            .foregroundColor(.white).padding()
            .background(Color.red).cornerRadius(8)
            .onAppear {
                Task { try? await Task.sleep(for: .seconds(2)); vm.error = nil }
            }
            .transition(.move(edge: .top))
    }
    
}

// MARK: – Sheets -----------------------------------------------------------

private extension TaskFormScreen {
    
    var datePickerSheet: some View {
        VStack {
            DatePicker("", selection: $vm.date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(.wBlue)
            Button("Done") { showDatePicker = false }
                .padding()
        }
        .presentationDetents([.fraction(0.65)])
    }
    
    func timePickerSheet(_ binding: Binding<Date>) -> some View {
        VStack {
            DatePicker("", selection: binding, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(.wBlue)
            Button("Done") {
                showStartPicker = false
                showEndPicker   = false
            }
            .padding()
        }
        .presentationDetents([.fraction(0.45)])
    }
}

// MARK: – Format helpers ----------------------------------------------------

private func dateLabel(_ d: Date) -> String {
    d.formatted(.dateTime.day().month(.abbreviated)).uppercased()
}
private func timeLabel(_ d: Date) -> String {
    d.formatted(date: .omitted, time: .shortened)
}

// MARK: – Preview -----------------------------------------------------------

struct TaskFormScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TaskFormScreen(){}
                .environmentObject(TaskFormViewModel())
        }
        .previewDevice("iPhone 15 Pro")
    }
}
