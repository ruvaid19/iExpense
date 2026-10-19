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

                List {
                    Section("Personal Expenses") {
                        ForEach(personalExpenses) { item in
                            expenseRow(item)
                                .listRowBackground(
                                    Color.white.opacity(0.12)
                                )
                        }
                        .onDelete(perform: removePersonalItems)
                    }

                    Section("Business Expenses") {
                        ForEach(businessExpenses) { item in
                            expenseRow(item)
                                .listRowBackground(
                                    Color.white.opacity(0.12)
                                )
                        }
                        .onDelete(perform: removeBusinessItems)
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
            }
            .navigationTitle("iExpense")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(
                                Color.white.opacity(0.16),
                                in: Circle()
                            )
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddExpense) {
                AddView(
                    expenses: expenses,
                    currencyCode: currencyCode
                )
            }
        }
        .tint(.white)
    }

    private var personalExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }

    private var businessExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Business" }
    }

    private func expenseRow(_ item: ExpenseItem) -> some View {
        HStack(spacing: 12) {
            Image(
                systemName: item.type == "Personal"
                    ? "person.fill"
                    : "briefcase.fill"
            )
            .font(.title3)
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 40, height: 40)
            .background(
                Color.white.opacity(0.13),
                in: RoundedRectangle(cornerRadius: 12)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(item.type)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
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
        .padding(.vertical, 6)
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
