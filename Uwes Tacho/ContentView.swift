//
//  ContentView.swift
//  Uwes Tacho
//
//  Created by Uwe Petersen on 01.06.24.
//

import SwiftUI
import os

struct ContentView: View {
    
    let animationDuration: Double = 0.5
    
    @State var logger = Logger(subsystem: "com.apple.liveUpdatesSample", category: "DemoView")
    @StateObject var locationsHandler = LocationsHandler.shared
    @State private var isLandscape = false
    @State private var mainUnitSpeed: UnitSpeed = UnitSpeed(forLocale: Locale.current)
    @State private var rotationAngle: Double = 0
    @State private var useAnimation: Bool = false
    
    var body: some View {
        VStack {

            Text("Uwes Tacho")
                .font(.largeTitle)
                .padding(.top)

            Divider()
            
            Group { // Views with the speed values
                
                SpeedView(unitSpeed: mainUnitSpeed, location: locationsHandler.lastLocation)
                    .rotation3DEffect(Angle(degrees: rotationAngle), axis: /*@START_MENU_TOKEN@*/(x: 0.0, y: 1.0, z: 0.0)/*@END_MENU_TOKEN@*/ )
                    .animation(.linear(duration: 0.1).delay(animationDuration), value: useAnimation) // change value while at 90 degrees and thus not visible

                Divider()
                
                if !self.isLandscape {
                    HStack() {
                        SpeedView(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation)
                            .onTapGesture {  changeMainUnitSpeedAnimated(.kilometersPerHour) }
                        SpeedView(unitSpeed: .milesPerHour, location: locationsHandler.lastLocation)
                            .onTapGesture { changeMainUnitSpeedAnimated(.milesPerHour) }
                    }
                }
                
                Spacer()

                HStack() {
                    if self.isLandscape {
                        SpeedView(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation)
                            .onTapGesture {  changeMainUnitSpeedAnimated(.kilometersPerHour) }
                        SpeedView(unitSpeed: .milesPerHour, location: locationsHandler.lastLocation)
                            .onTapGesture {  changeMainUnitSpeedAnimated(.milesPerHour) }
                    }
                    SpeedView(unitSpeed: .knots, location: locationsHandler.lastLocation)
                        .onTapGesture {  changeMainUnitSpeedAnimated(.knots) }
                    SpeedView(unitSpeed: .metersPerSecond, location: locationsHandler.lastLocation)
                        .onTapGesture {  changeMainUnitSpeedAnimated(.metersPerSecond) }
                }

            }
            .foregroundColor(locationsHandler.updatesStarted ? .primary : .secondary) //gray out speed values, when not updating.

            Divider()
            Spacer()
            
            HStack() {

                Text("Count: \(self.locationsHandler.count)")
                    .padding(.horizontal)

                Spacer()

                Button(self.locationsHandler.updatesStarted ? "Stop" : "Start") {
                    self.locationsHandler.updatesStarted ? self.locationsHandler.stopLocationUpdates() : self.locationsHandler.startLocationUpdates()
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("Count: \(self.locationsHandler.count)") // same text, but hidden, for symmetry
                    .padding(.horizontal)
                    .hidden()
            }
        }
        .onAppear() {
            locationsHandler.startLocationUpdates()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
            self.isLandscape = scene.interfaceOrientation.isLandscape
        }

    }
    
    /// Animates the change of the main speed unit like a flipping card
    /// - Parameter mainUnitSpeed: the new speed unit to be display.
    fileprivate func changeMainUnitSpeedAnimated(_ mainUnitSpeed: UnitSpeed) {
        self.mainUnitSpeed = mainUnitSpeed
        useAnimation.toggle()
        // rotate away (i.e. to 90 degrees)
        withAnimation(.easeInOut(duration: animationDuration)) {
            rotationAngle += 90
        }
        // now quickly flip from 90 to 270 degrees, such that this transition is not visible.
        // At the same instant the value is changed (happens separately in separate code)
        withAnimation(.easeInOut(duration: 0.001).delay(animationDuration)) {
            rotationAngle = 270
        }
        // and finally rotate back in from 270 degrees, such that rotation direction is continued
        withAnimation(.easeInOut(duration: animationDuration).delay(animationDuration)) {
            rotationAngle += 90
        }
    }
}

//#Preview {
//    ContentView()
//}
