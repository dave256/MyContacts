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
        NavigationStack {
            List {
                ForEach(app.contacts) { c in
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
        }
        // when set to true, view shows
        // when view is dismissed, variable is automatically set back to false
        .sheet(isPresented: $isShowingAddContact) {
            AddContact()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel(contacts: .mock))
    }
}
