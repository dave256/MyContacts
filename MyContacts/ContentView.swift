//
//  ContentView.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppModel
    /// for tracking size of cells via preference key
    @State private var cellHeight: CGFloat?
    @State private var isShowingAddContact = false

    var body: some View {
        NavigationStack(path: $app.navPath) {
            List {
                ForEach(app.contacts) { c in
                    // note the value parameter must be hashable
                    NavigationLink(value: NavPathCase.contact(c)) {
                        // make cells all the same height even if some Text's are blank
                        ContactCell(contact: c)
                            .foregroundColor(.primary)
                            .frame(height: cellHeight)
                            .sharedHeightUsingMax {
                                cellHeight = $0
                            }
                            .padding([.top, .bottom], 2)
                    }
                }
                .onDelete(perform: deleteContacts)
            }
            .navigationTitle("Contacts")
            // need a navigation stack to show a toolbar at top of window
            .toolbar {
                Button {
                    isShowingAddContact = true
                } label: {
                    // see SF Symbols Mac app for various system images you can use
                    Image(systemName: "plus")
                }
            }
            // now we can use enum's potential mutliple cases to go to different destinations
            .navigationDestination(for: NavPathCase.self) { navItem in
                switch navItem {
                    // if it's the contact case of the enum use its associated value to get the contact
                case let .contact(c):
                    EditContact(contactID: c.id)
                }
            }
            // note: can have multiple .navigationDestination modifiers for different types
        }
        // when set to true, view shows
        // when view is dismissed, variable is automatically set back to false
        .sheet(isPresented: $isShowingAddContact) {
            AddContact()
        }
    }

    /// called from .onDelete view modifier to the ForEach view for swiping to delete a row
    /// - Parameter offsets: indices to delete
    func deleteContacts(at offsets: IndexSet) {
        app.removeContacts(at: offsets)
    }

}

struct ContentView_Previews: PreviewProvider {

    struct Preview: View {
        // note it is important that the .mock array sent to contacts
        // contains constants so we can set the navPath to include a contact
        // (.jane in this case) matching the id of one of the elements in the array
        //
        // this is useful for testing so don't need to keep navigation to view we want to test
        // also useful for deeplinking to a screen in app (think of clicking on a URL that opens a specific view in this app)
        //
        // could also be useful for state restoration
        // it may not work in this case since the id's are not stable across app launches
        //
        @StateObject private var appModel = AppModel(
            contacts: .mock, navPath: [.contact(.jane)])

        // note we could also put the path in a situation not reachable by running it directly
        // by putting two contacts on the navigation stack
//        @State private var appModel = AppModel(
//            contacts: .mock, navPath: [.contact(.jane), .contact(.george)])

        var body: some View {
            ContentView()
                .environmentObject(appModel)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
