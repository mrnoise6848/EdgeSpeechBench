import SwiftUI
import SwiftData

// Preserve the existing template's local-item functionality and stored data.
struct ExistingItemsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @State private var errorMessage: String?
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink { Text(item.timestamp.formatted()) } label: { Text(item.timestamp.formatted()) }
            }.onDelete { offsets in
                for index in offsets { context.delete(items[index]) }
                save()
            }
        }.navigationTitle("Existing local items")
        .toolbar {
            EditButton()
            Button("Add Item", systemImage: "plus") { context.insert(Item(timestamp: Date())); save() }
        }
        .alert("Storage error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
    private func save() {
        do { try context.save() } catch { context.rollback(); errorMessage = error.localizedDescription }
    }
}
