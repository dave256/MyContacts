//
//  AddContact.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct AddContact: View {
    @EnvironmentObject var app: AppModel
    // an environment variable for dimissing a view when called as function
    @Environment(\.dismiss) var dismiss

    @State private var contact = Contact.blank

    var body: some View {
        VStack {
            // show that we can use @ViewBuilder computed property to keep the body simpler
            cancelAndAddButtons

            EditContactForm(contact: $contact, startingFocus: .first)
        }
    }

    // show that can use @ViewBuilder computed property with "some View" type
    // to simplify the body
    // could also have:
    // @ViewBuilder func cancelAndAddButtons() -> some View
    // and then would need () in body (i.e., cancelAndAddButtons() instead of
    // cancelAndAddButton above in the body)
    @ViewBuilder var cancelAndAddButtons: some View {
        HStack {
            Button("Cancel", role: .destructive) {
                // use the @Environment(\.dismiss) key to dismiss the sheet
                dismiss()
            }
            Spacer()
            Button("Add") {
                // can call a method in the view to reduce code here
                addContact()
            }
            .disabled(contact.isEmpty)
        }
        .padding()
    }

    func addContact() {
        app.addContact(contact)
        // use the @Environment(\.dismiss) key to dismiss the sheet
        dismiss()
    }
}

struct AddContact_Previews: PreviewProvider {
    static var previews: some View {
        AddContact()
    }
}
