//
//  AppModel.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI
import IdentifiedCollections

// demo a technique for multiple destinations
// using an enum with associated values
// in this app, we are only navigation to a Contact type so only one case
// the stored values in the NavigationStack must be Hashable so make the
// enum Hashable (which means all the associated values - EditContactModel) must
// be equatable and hashable to get the automatic conformance
enum NavPathCase: Equatable, Hashable {
    case contact(EditContactModel)
}

/// protocol so can store a ContactSaver object in pushed NavigationStack views so they can save the changes they make
@MainActor
protocol ContactSaver: AnyObject {
    func updateExistingContact(_ contact: Contact)
}

/// model object for storing the app's data
final class AppModel: ObservableObject, ContactSaver {

    enum Destination {
        case add
        case contact(EditContactModel)
    }

    // mark fields @Publishable so that changes in their values cause view to redraw
    @Published var contacts: IdentifiedArrayOf<Contact>

    @Published var destination: Destination?

    @Published var navPath: [NavPathCase] = []


    ///
    /// - Parameters:
    ///   - contacts: optional array to initialize with for testing
    ///   - destination: optional destination for deep linking
    init(contacts: [Contact]? = nil, destination: Destination? = nil) {
        if let contacts {
            self.contacts = IdentifiedArrayOf(uniqueElements: contacts.sorted())
        } else {
            // if none provided, try to load from file
            self.contacts = loadContacts()
            #warning("for testing, if no contacts, use mock data")
            if self.contacts.isEmpty {
                self.contacts = IdentifiedArrayOf(uniqueElements: [Contact].mock.sorted())
            }
        }
        self.destination = destination
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

    /// update value of existing contact (gives ContactSaver conformance)
    ///
    /// note the id never changes so we use the id key to find the appropriate contact to update
    /// - Parameter contact: contact with values to save
    func updateExistingContact(_ contact: Contact) {
        contacts[id: contact.id] = contact
        // sort since name may have changed
        contacts.sort()
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

extension AppModel {
    // a version that deep links into navigation stack; useful for previews and while testing
    static var deepLink: AppModel {
        let contacts = Contact.mockArray
        let c = contacts[0]
        let app = AppModel(contacts: contacts)
        let editModel = EditContactModel(parentModel: app, destination: .edit(.first), contact: c)
        app.destination = .contact(editModel)
        return app
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
