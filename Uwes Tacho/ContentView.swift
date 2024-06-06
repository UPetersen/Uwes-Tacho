//
//  ContentView.swift
//  Uwes Tacho
//
//  Created by Uwe Petersen on 01.06.24.
//

import SwiftUI
import os

struct ContentView: View {
    
    @State var logger = Logger(subsystem: "com.apple.liveUpdatesSample", category: "DemoView")
    @StateObject var locationsHandler = LocationsHandler.shared
    @State private var isLandscape = false

    var body: some View {
        VStack {

            Text("Uwes Tacho")
                .font(.largeTitle)
                .padding(.top)

                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
                    self.isLandscape = scene.interfaceOrientation.isLandscape
                }

            
            Divider()
            
            SpeedView(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation)
            
            Divider()
            
            if !self.isLandscape {
                HStack() {
                    SpeedView(unitSpeed: .metersPerSecond, location: locationsHandler.lastLocation)
                    SpeedView(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation)
                }
            }
            
            Spacer()

            HStack() {
                if self.isLandscape {
                    SpeedView(unitSpeed: .metersPerSecond, location: locationsHandler.lastLocation)
                    SpeedView(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation)
                }
                SpeedView(unitSpeed: .milesPerHour, location: locationsHandler.lastLocation)
                SpeedView(unitSpeed: .knots, location: locationsHandler.lastLocation)
            }

            Divider()
            Spacer()

            Text("Count: \(self.locationsHandler.count)")

            Spacer()
            Button(self.locationsHandler.updatesStarted ? "Stop" : "Start") {
                self.locationsHandler.updatesStarted ? self.locationsHandler.stopLocationUpdates() : self.locationsHandler.startLocationUpdates()
            }
            .buttonStyle(.bordered)

        }
        .onAppear() {
            locationsHandler.startLocationUpdates()
        }
    }

}

#Preview {
    ContentView()
}
