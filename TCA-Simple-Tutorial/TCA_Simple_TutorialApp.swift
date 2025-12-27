//
//  TCA_Simple_TutorialApp.swift
//  TCA-Simple-Tutorial
//
//  Created by OneTen on 12/20/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_Simple_TutorialApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: TCA_Simple_TutorialApp.store)
        }
    }
}
