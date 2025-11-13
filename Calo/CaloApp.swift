//
//  CaloApp.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

@main
struct CaloApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
