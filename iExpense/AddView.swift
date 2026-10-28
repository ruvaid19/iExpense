//
//  AddView.swift
//  iExpense
//
//  Created by Ruvaid on 13/10/26.
//

import SwiftUI

struct AddView: View {
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    @FocusState private var amountIsFocused: Bool

    let types = ["Business", "Personal"]
    var expenses: Expenses
    var currencyCode: String

    @Environment(\.dismiss) var dismiss

    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.28, blue: 0.30),
            Color(red: 0.08, green: 0.43, blue: 0.42),
            Color(red: 0.25, green: 0.58, blue: 0.48)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                Form {
                    Section("Expense Details") {
                        TextField("Name", text: $name)

                        Picker("Type", selection: $type) {
                            ForEach(types, id: \.self) { item in
                                Text(item)
                            }
                        }

                        TextField(
                            "Amount",
                            value: $amount,
                            format: .currency(code: currencyCode)
                        )
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()

                                Button("Done") {
                                    amountIsFocused = false
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.30))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = ExpenseItem(
                            name: name,
                            type: type,
                            amount: amount
                        )

                        expenses.items.append(item)
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty
                    )
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .tint(.white)
    }
}

#Preview {
    AddView(
        expenses: Expenses(),
        currencyCode: "INR"
    )
}
