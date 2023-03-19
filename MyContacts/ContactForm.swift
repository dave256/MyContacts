//
//  ContactForm.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct ContactForm: View {
    let contact: Contact

    var body: some View {
        Form {
            Text(contact.firstName)
            Text(contact.lastName)
            Text(contact.email)
            Text(contact.phone)
        }
    }
}

struct EditContactForm: View {
    @Binding var contact: Contact
    let startingFocus: EditContactModel.Field?

    init(contact: Binding<Contact>, startingFocus: EditContactModel.Field? = nil) {
        // note how to initialize a binding with leading underscore
        self._contact = contact
        self.startingFocus = startingFocus
    }

    // use @FocusState wrapper for setting focus - see TextField modifiers below
    @FocusState var focus: EditContactModel.Field?

    var body: some View {
        Form {
            // use Group so we can apply autocorrectionDisabled to all the TextFields
            Group {
                TextField("First", text: $contact.firstName)
                    .focused(self.$focus, equals: .first)
                TextField("Last", text: $contact.lastName)
                    .focused(self.$focus, equals: .last)
                TextField("Email", text: $contact.email)
                    .focused(self.$focus, equals: .email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .autocorrectionDisabled()
            TextField("Mobile Phone", text: $contact.phone)
                .focused(self.$focus, equals: .phone)
                .keyboardType(.phonePad)
        }
        .onAppear {
            focus = startingFocus
        }
    }
}

struct ContactForm_Previews: PreviewProvider {

    // make a helper view since can't make state in the static var previews
    struct Preview: View {
        @State private var contact = Contact.mock

        var body: some View {
            EditContactForm(contact: $contact)
        }
    }

    static var previews: some View {
        Preview()
    }
}

