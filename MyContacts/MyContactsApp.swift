//
//  MyContactsApp.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

@main
struct MyContactsApp: App {
    // initial model
    #warning("loading with sample data during development")
    @State private var app = AppModel(contacts: .mock)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
        }
    }
}
