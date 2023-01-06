//
//  AppModel.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI
import IdentifiedCollections

/// model object for storing the app's data
final class AppModel: ObservableObject {
    // mark fields @Publishable so that changes in their values cause view to redraw

    // the list of contacts; try to load from JSON file
    @Published var contacts: IdentifiedArrayOf<Contact> = loadContacts()

    /// 
    /// - Parameter contacts: if contacts is not empty, it overwrites contacts that were potentially loaded from JSON file
    init(contacts: [Contact] = []) {
        if !contacts.isEmpty {
            self.contacts = IdentifiedArrayOf(uniqueElements: contacts.sorted())
        }
    }

    /// get a contact by its id
    /// - Parameter id: id of contact to get
    /// - Returns: the Contact with that id or nil if no Contact with that ID
    func contact(id: Contact.ID) -> Contact? {
        return contacts[id: id]
    }

    /// adds Contact to array in sorted order
    /// - Parameter contact: contact to add
    func addContact(_ contact: Contact) {
        self.contacts.insertInSortedOrder(contact)
    }

    /// removes contacts at specified indices (for use with ForEach .onDelete in a View )
    /// - Parameter offsets: indices of contacts to delete
    func removeContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }

    /// force contacts to be sorted
    func sortContacts() {
        self.contacts.sort()
    }

    /// stores the contacts to contacts.json file in the Documents directory of the app's sandbox
    func storeContacts() {
        let fm = FileManager()
        if let url = fm.urls(for: .documentDirectory, in: .userDomainMask).last {
            let dataURL = url.appendingPathComponent("contacts.json")
            let coder = JSONEncoder()
            if let data = try? coder.encode(contacts) {
                do {
                    try data.write(to: dataURL)
                } catch {
                    print("erorr saving")
                }
            }
        }
    }
}

// standalone function so can call when declaring contacts instance variable in AppModel class
func loadContacts() -> IdentifiedArrayOf<Contact> {
    let fm = FileManager()
    if let url = fm.urls(for: .documentDirectory, in: .userDomainMask).last {
        let dataURL = url.appendingPathComponent("contacts.json")
        if let data = try? Data(contentsOf: dataURL) {
            let decoder = JSONDecoder()
            if let contacts = try? decoder.decode([Contact].self, from: data) {
                return IdentifiedArrayOf(uniqueElements: contacts.sorted())
            }
        }
    }
    // return empty array if failed to load (will automatically convert literal to an IdentifiedArrayOf)
    return []
}
