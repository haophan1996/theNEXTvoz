//
//  theNEXTvozApp.swift
//  theNEXTvoz
//
//  Created by Hao Phan on 1/17/22.
//

import SwiftUI

@main
struct theNEXTvozApp: App {
    @StateObject var monitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            HomePage()
                .environmentObject(monitor)
        }
    }
}
