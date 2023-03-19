//
//  ContentView.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI
import SwiftUINavigation

struct ContentView: View {
    @EnvironmentObject var app: AppModel
    /// for tracking size of cells via preference key
    @State private var cellHeight: CGFloat?
    @State private var isShowingAddContact = false

    var body: some View {
        NavigationStack(path: $app.navPath) {
            List {
                ForEach(app.contacts) { c in
                    Button {
                        app.destination = .contact(EditContactModel(parentModel: app, contact: c))
                    } label: {
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
                    app.destination = .add
                } label: {
                    // see SF Symbols Mac app for various system images you can use
                    Image(systemName: "plus")
                }
            }
            .sheet(unwrapping: $app.destination, case: /AppModel.Destination.add) { _ in
                AddContact()
            }
            .navigationDestination(unwrapping: $app.destination, case: /AppModel.Destination.contact) { $model in
                EditContact(model: model)
            }

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
        // for previwing, use a deep link
        @StateObject private var appModel = AppModel.deepLink

        var body: some View {
            ContentView()
                .environmentObject(appModel)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
