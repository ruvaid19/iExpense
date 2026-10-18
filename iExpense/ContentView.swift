//
//  ContentView.swift
//  iExpense
//
//  Created by Ruvaid on 12/10/26.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode(
                [ExpenseItem].self,
                from: savedItems
            ) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false

    private let currencyCode =
        Locale.current.currency?.identifier ?? "INR"

    var body: some View {
        NavigationStack {
            List {
                Section("Personal Expenses") {
                    ForEach(personalExpenses) { item in
                        expenseRow(item)
                    }
                    .onDelete(perform: removePersonalItems)
                }

                Section("Business Expenses") {
                    ForEach(businessExpenses) { item in
                        expenseRow(item)
                    }
                    .onDelete(perform: removeBusinessItems)
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(
                    expenses: expenses,
                    currencyCode: currencyCode
                )
            }
        }
    }

    private var personalExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }

    private var businessExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Business" }
    }

    private func expenseRow(_ item: ExpenseItem) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)

                Text(item.type)
            }

            Spacer()

            Text(
                item.amount,
                format: .currency(code: currencyCode)
            )
            .font(.headline)
            .foregroundStyle(
                item.amount < 10 ? .green :
                item.amount < 100 ? .orange :
                .red
            )
        }
    }

    private func removePersonalItems(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { personalExpenses[$0].id }

        expenses.items.removeAll { item in
            itemsToRemove.contains(item.id)
        }
    }

    private func removeBusinessItems(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { businessExpenses[$0].id }

        expenses.items.removeAll { item in
            itemsToRemove.contains(item.id)
        }
    }
}

#Preview {
    ContentView()
}
