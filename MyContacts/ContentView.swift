//
//  ContentView.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(app.contacts) { c in
                    ContactCell(contact: c)
                }
            }
            .navigationTitle("Contacts")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel(contacts: .mock))
    }
}
