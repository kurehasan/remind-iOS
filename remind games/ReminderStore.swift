//
//  ReminderStore.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/05/10.
//

import Combine
import Foundation
import CoreData

final class ReminderStore: ObservableObject {
    @Published var context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchAll() -> [ReminderEntity] {
        let request: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderEntity.date, ascending: true)]
        do { return try context.fetch(request) }
        catch { print("Fetch error: \(error)"); return [] }
    }

    func add(_ reminder: ReminderEntity) {
        context.insert(reminder)
        save()
    }

    func delete(_ entity: ReminderEntity) {
        context.delete(entity)
        save()
    }

    func toggleChecked(_ entity: ReminderEntity) {
        entity.isChecked.toggle()
        save()
    }

    private func save() {
        do { try context.save() }
        catch { print("Save error: \(error)"); context.rollback() }
    }
}

