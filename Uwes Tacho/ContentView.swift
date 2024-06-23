//
//  ContentView.swift
//  Uwes Tacho
//
//  Created by Uwe Petersen on 01.06.24.
//

import SwiftUI
import UIKit
import os

struct ContentView: View {
    
    let animationDuration: Double = 0.5
    
//    @State var logger = Logger(subsystem: "com.UNPP.Uwes-tacho", category: "ContentView")
    @StateObject var locationsHandler = LocationsHandler.shared
    @State private var isLandscape = false
    @State private var mainUnitSpeed: UnitSpeed = UnitSpeed(forLocale: Locale.current)
    @State private var rotationAngleForAnimation: Double = 0
    @State private var useAnimation: Bool = false
    @State private var badGPSSignal: Bool = false
    @State private var startDate: Date = Date.now
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
//
    var body: some View {
        VStack {

            Text("Uwes Tacho")
                .font(.largeTitle)
                .padding(.top)

            Divider()
            
            Group { // Views with the speed values
                
                SpeedView(unitSpeed: mainUnitSpeed, location: locationsHandler.lastLocation)
                    .rotation3DEffect(Angle(degrees: rotationAngleForAnimation), axis: /*@START_MENU_TOKEN@*/(x: 0.0, y: 1.0, z: 0.0)/*@END_MENU_TOKEN@*/ )
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

                Text("Zähler: \(self.locationsHandler.count)")
                    .padding(.horizontal)

                Spacer()

                Button(self.locationsHandler.updatesStarted ? "Stop" : "Start") {
                    self.locationsHandler.updatesStarted ? self.locationsHandler.stopLocationUpdates() : self.locationsHandler.startLocationUpdates()
                }
                .buttonStyle(.bordered)

                Spacer()

//                Text(locationsHandler.lastLocation.timestamp.formatted(date: .omitted, time: .standard))
//                    .padding(.horizontal)
                // For symmetry: same text on the right side as on the left side, but hidden (to retain symmetry, i.e. the button in the middle)
                Text("Zähler: \(self.locationsHandler.count)")
                    .padding(.horizontal)
                    .hidden()
            }
        }
        .onAppear() {
            locationsHandler.startLocationUpdates()
            UIApplication.shared.isIdleTimerDisabled = true // App stays open, just like navigation apps do
            startDate = Date.now
            print("Start Date: \(startDate)")
        }
        // react on change of orientation (portrait/landscape)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
            self.isLandscape = scene.interfaceOrientation.isLandscape
        }
        .onDisappear()  {
            locationsHandler.stopLocationUpdates()
            UIApplication.shared.isIdleTimerDisabled = false
            print("In .onDisappear.")
        }
        // Show alert when bad GPS Signal, but do not show within the first four seconds after starting of the app
        // Remark: in case, that the app starts with a bad signal, this .onReceive gets never called. Fort these cases
        // there a timer is used additionally, that fires after four seconds to assess the state and show the respective
        // bad GPS signal alert.
        .onChange(of: locationsHandler.lastLocation.speedAccuracy, initial: false) { oldValue, newValue in
            print("Distance to inital date: \(startDate.distance(to: Date.now))")
            if startDate.distance(to: Date.now) >= 4.0 && newValue < 0 {
                badGPSSignal = true // show bad gps information only after first two seconds
            } else {
                badGPSSignal = false
            }
        }
        // Timer that fires four seconds after app start and shows the bad GPS alert if necessary.
        // The timer is disable thereafter.
        .onReceive(timer) { fireDate in
            print("\(fireDate), elapsed time: \(fireDate.timeIntervalSince(startDate))")
            let elapsedTime = fireDate.timeIntervalSince(startDate)
            if elapsedTime >= 4 {
                timer.upstream.connect().cancel()
                if locationsHandler.lastLocation.speedAccuracy < 0 {
                    badGPSSignal = true
                }
            }
        }
        .alert(isPresented: $badGPSSignal) {
            Alert(title: Text("Kein ausreichender GPS-Empfang"))
        }

    }
    
    /// Animates the change of the main speed unit like a flipping card
    /// - Parameter mainUnitSpeed: the new speed unit to be display.
    fileprivate func changeMainUnitSpeedAnimated(_ mainUnitSpeed: UnitSpeed) {
        self.mainUnitSpeed = mainUnitSpeed
        useAnimation.toggle()
        // rotate away (i.e. to 90 degrees)
        withAnimation(.easeInOut(duration: animationDuration)) {
            rotationAngleForAnimation += 90
        }
        // now quickly flip from 90 to 270 degrees, such that this transition is not visible.
        // At the same instant the value is changed (happens separately in separate code)
        withAnimation(.easeInOut(duration: 0.00000001).delay(animationDuration)) {
            rotationAngleForAnimation = 270
        }
        // and finally rotate back in from 270 degrees, such that rotation direction is continued
        withAnimation(.easeInOut(duration: animationDuration).delay(animationDuration)) {
            rotationAngleForAnimation += 90
        }
    }
}

//#Preview {
//    ContentView()
//}
