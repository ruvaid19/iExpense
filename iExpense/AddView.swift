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

    let types = ["Business", "Personal"]

    var expenses: Expenses

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) { item in
                        Text(item)
                    }
                }

                TextField(
                    "Amount",
                    value: $amount,
                    format: .currency(code: "USD")
                )
                .keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let expense = ExpenseItem(
                            name: name,
                            type: type,
                            amount: amount
                        )

                        expenses.items.append(expense)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddView(expenses: Expenses())
}
