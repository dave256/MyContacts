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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel(contacts: .mock))
    }
}
