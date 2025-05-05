//
//  TaskFormScreen.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//


import SwiftUI

//// MARK: - Screen ------------------------------------------------------------

struct TaskFormScreen: View {
    
    // ── State ──
    @Environment(\.dismiss) private var dismiss
    @State private var title        = ""
    @State private var date         = Date()
    @State private var startTime    = Date()
    @State private var endTime      = Date()
    @State private var notes        = ""
    @State private var repeatRule   = RepeatRule.none
    
    @State private var categories   = [
        Category(name: "Work"),
        Category(name: "Study"),
        Category(name: "Household")
    ]
    @State private var selectedCat  : Category? = nil
    
    // sheet / dialog flags
    @State private var showDatePicker  = false
    @State private var showStartPicker = false
    @State private var showEndPicker   = false
    @State private var showRepeatSheet = false
    @State private var showAddCatAlert = false
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Title
                    LabeledBox("Title") {
                        HStack {
                            TextField("Title", text: $title)
                                .foregroundColor(.white)
                            if !title.isEmpty {
                                Button { title = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.wGreyText)
                                }
                            }
                        }
                    }
                    
                    // Date + time chips
                    HStack(spacing: 12) {
                        Chip(text: dateLabel(date), filled: true) {
                            showDatePicker = true
                        }
                        Chip(text: timeLabel(startTime)) {
                            showStartPicker = true
                        }
                        Chip(text: timeLabel(endTime)) {
                            showEndPicker = true
                        }
                    }
                    
                    // Categories chips
                    FlowLayout(spacing: 12, lineSpacing: 12) {
                        ForEach(categories) { cat in
                            let on = selectedCat == cat
                            Chip(text: cat.name, filled: on) {
                                selectedCat = on ? nil : cat
                            }
                        }
                        Chip(text: "+") { showAddCatAlert = true }
                    }
                    
                    // Notes
                    Text("Notes")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Value")
                                .foregroundColor(.wGreyText)
                                .padding(8)
                        }
                        TextEditor(text: $notes)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .frame(height: 120)
                    .background(Color.wSurface)
                    .cornerRadius(12)
                    
                    // Repeat
                    HStack {
                        Text("Repeat")
                            .foregroundColor(.white)
                        Spacer()
                        Chip(text: repeatRule.rawValue) {
                            showRepeatSheet = true
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    Button {
                        // TODO: save task
                    } label: {
                        Text("SAVE")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wBlue)
                            .cornerRadius(12)
                    }
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        // MARK: navigation bar
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New task")
        .preferredColorScheme(.dark)
        
        // MARK: sheets & dialogs
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
        .sheet(isPresented: $showStartPicker) { timePickerSheet(binding: $startTime) }
        .sheet(isPresented: $showEndPicker) { timePickerSheet(binding: $endTime) }
        .confirmationDialog("Repeat",
                            isPresented: $showRepeatSheet,
                            titleVisibility: .visible) {
            ForEach(RepeatRule.allCases, id: \.self) { r in
                Button(r.rawValue) { repeatRule = r }
            }
        }
        .alert("New category", isPresented: $showAddCatAlert) {
            Button("Add") {
                categories.append(Category(name: "New"))
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Adds a placeholder category named “New”.")
        }
    }
}

// MARK: – Sheets ------------------------------------------------------------

private extension TaskFormScreen {
    
    var datePickerSheet: some View {
        VStack {
            DatePicker("",
                       selection: $date,
                       displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .tint(.wBlue)
            Button("Done") { showDatePicker = false }
                .padding()
        }
        .presentationDetents([.fraction(0.45)])
    }
    
    func timePickerSheet(binding: Binding<Date>) -> some View {
        VStack {
            DatePicker("",
                       selection: binding,
                       displayedComponents: [.hourAndMinute])
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(.wBlue)
            Button("Done") {
                showStartPicker = false
                showEndPicker   = false
            }
            .padding()
        }
        .presentationDetents([.fraction(0.35)])
    }
}

// MARK: – Format helpers ----------------------------------------------------

private func dateLabel(_ d: Date) -> String {
    d.formatted(.dateTime.day().month(.abbreviated)).uppercased()
}
private func timeLabel(_ d: Date) -> String {
    d.formatted(date: .omitted, time: .shortened)
}


struct TaskFormScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { TaskFormScreen() }
            .previewDevice("iPhone 15 Pro")
    }
}

