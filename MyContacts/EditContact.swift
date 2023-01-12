//
//  EditContact.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct EditContact: View {
    var contactID: Contact.ID

    @EnvironmentObject var app: AppModel
    @State private var draftContact = Contact.blank
    @State private var isEditing = false

    var appContact: Contact {
        // get value from app source of truth
        // instead of crashing using a blank Contact if it fails
        // this should never happen (assuming passed an element from
        // the AppModel's contacts)
        // might want to output this to error log
        guard let c = app.contact(id: contactID) else { return .blank }
        return c
    }

    var hasChanges: Bool {
        return draftContact != appContact
    }

    var body: some View {
        VStack {
            if !isEditing {
                // always show source of truth when not editing (from computed property)
                ContactForm(contact: appContact)
            } else {
                EditContactForm(contact: $draftContact, startingFocus: .first)
                // hide the back button when editing and force to use Cancel or Done first
                    .navigationBarBackButtonHidden()
            }
        }
        // this view needs to be shown in a navigation stack for toolbar to be visible
        // in this case, this view is pushed onto the navigation stack from previous view
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        isEditing.toggle()
                        Task {
                            // to be safe, wait for TextField to resign focus and save to draftContact
                            // then can overwrite draftContact with data from app
                            _ = try? await Task.sleep(nanoseconds: 300 * NSEC_PER_MSEC)
                            draftContact = app.contact(id: contactID) ?? .blank
                        }
                    }
                    // when no changes disable so not really visible
                    .disabled(!hasChanges)
                    // show in red to indicate possible data loss
                    .tint(.red)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                // choose appropriate label based on state
                Button(isEditing ? "Done": "Edit") {
                    if isEditing {
                        // if we were editing, update the actual contact
                        app.updateExistingContact(draftContact)
                    } else {
                        // start editing with existing contact
                        draftContact = appContact
                    }
                    isEditing.toggle()
                }
            }
        }
    }
}

struct EditContact_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            EditContact(contactID: Contact.mock.id)
                .environmentObject(AppModel(contacts: .mock))
        }
    }
}
