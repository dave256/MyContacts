//
//  EditContact.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

/// view model for controling the EditCotnactView
@MainActor
final class EditContactModel: ObservableObject {

    /// parent model that presented the view that this model is showing
    /// need this so any changes we make here can be saved so previous view on the stack is updated
    weak var parentModel: ContactSaver?
    // contact we are viewing/editing
    @Published var contact: Contact
    // whether or not we are editing
    @Published var isEditing: Bool
    // Contact displayed while we are editing
    @Published var draftContact: Contact

    /// if any edits have been made
    var hasChanges: Bool { contact != draftContact }

    ///
    /// - Parameters:
    ///   - parentModel: the model for the presenting view so when we make changes, we save updates to it
    ///   - contact: the contact we are viewing/editing
    ///   - isEditing: whether or not we are editing (so can deep link into this view with editing initiated)
    init(parentModel: ContactSaver? = nil, contact: Contact, isEditing: Bool) {
        self.parentModel = parentModel
        self.contact = contact
        self.isEditing = isEditing
        self.draftContact = contact
    }

    /// action when Edit button is pressed to start editing the contact
    func startEditing() {
        // set draftContact so we start editing with the current value
        draftContact = contact
        isEditing = true
    }

    /// action when Cancel button is pressed
    func cancelEditing() {
        // just need to end editing
        isEditing = false
    }

    /// action when Done button is pressed to end editing and save the changes
    func saveChanges() {
        // when save, we need to store the change in contact
        contact = draftContact
        // and propogate the change to the previous view model so it can update
        // if that view was not the root view model that contains the AppModel source of truth, it
        // would propagate the change to that previous view, and so on until the AppModel is reached
        parentModel?.updateExistingContact(contact)
        isEditing = false
    }

    /// determine appropriate action based on current state of isEditing
    func editButtonPressed() {
        if isEditing {
            saveChanges()
        } else {
            startEditing()
        }
    }
}

/// it needs to be Hashable (which requires Editable) to use as a NavigationLink value
extension EditContactModel: Equatable, Hashable {
    // need to mark as nonisolated since EditContactModel is on the MainActor
    // I think this is ok since all we're doing is check if the memory addresses are equal
    // would be concerned if we were checking published properties
    nonisolated static func == (lhs: EditContactModel, rhs: EditContactModel) -> Bool {
        // use object identity (i.e., since these are reference types, check if exact same object in memory)
        return lhs === rhs
    }

    // need to make hashable so can be used as a NavigationLink value
    func hash(into hasher: inout Hasher) {
        // simplest thing to do is use the ObjectIdentifer (which I believe gives the memory address)
        hasher.combine(ObjectIdentifier(self))
    }
}

struct EditContact: View {
    /// the EditContactModel complete controls the state and responds to the changes
    @ObservedObject var model: EditContactModel

    var body: some View {
        VStack {
            if !model.isEditing {
                // always show source of truth when not editing (from computed property)
                ContactForm(contact: model.contact)
            } else {
                // when editing show the draftContact
                // note since the draftContact is stored in the EditContactModel that continues to exist
                // we don't need to worry about the binding to it going away and causing a crash
                EditContactForm(contact: $model.draftContact, startingFocus: .first)
                // hide the back button when editing and force to use Cancel or Done first
                    .navigationBarBackButtonHidden()
            }
        }
        // this view needs to be shown in a navigation stack for toolbar to be visible
        // in this case, this view is pushed onto the navigation stack from previous view
        .toolbar {
            if model.isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        model.cancelEditing()
                    }
                    // when no changes disable so not really visible
                    .disabled(!model.hasChanges)
                    // show in red to indicate possible data loss
                    .tint(.red)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                // choose appropriate label based on state
                Button(model.isEditing ? "Done": "Edit") {
                    model.editButtonPressed()
                }
            }
        }
    }
}

struct EditContact_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            EditContact(model: EditContactModel(contact: .mock, isEditing: true))
        }
    }
}
