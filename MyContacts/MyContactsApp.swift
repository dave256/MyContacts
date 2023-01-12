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
    @StateObject private var app = AppModel.deepLink

    // can re-insert these anytime we want to start fresh with the mock data
    // and then onece put app in background, they will save and could comment out again
    //    #warning("loading with sample data during development")
    //    @State private var app = AppModel(contacts: .mock)

    
    // for detecting when app goes to background (Home button or swipe up to dimiss app)
    // note pressing the stop button in Xcode quits immediately and it wont' save
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)

                .onChange(of: scenePhase) { phase in
                    switch phase {

                    case .background:
                        // when app enters background, save the contacts to JSON file
                        app.storeContacts()

                    default:
                        break
                    }
                }
        }
    }
}
