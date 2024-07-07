//
//  ContentView.swift
//  Uwes Tacho
//
//  Created by Uwe Petersen on 01.06.24.
//

import SwiftUI
import UIKit
import os
import CoreLocation

struct ContentView: View {
    
    let animationDuration: Double = 0.5
    
    @StateObject var locationsHandler = LocationsHandler.shared
    @State private var isLandscape = false
    @State private var mainUnitSpeed: UnitSpeed = UnitSpeed(forLocale: Locale.current)
    @State private var rotationAngleForAnimation: Double = 0
    @State private var useAnimation: Bool = false
    @State private var badGPSSignal: Bool = false
    @State private var startDate: Date = Date.now
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
//

    func ratioLengthToMaxNumber(location: CLLocation, unit: UnitSpeed) -> Double {
        let speedInKmh = Measurement<UnitSpeed>(value: location.speed, unit: .metersPerSecond).converted(to: .kilometersPerHour).value
        let speed      = Measurement<UnitSpeed>(value: location.speed, unit: .metersPerSecond).converted(to: unit).value
                
        let digits    = String(speed.formatted(.number.precision(.fractionLength(0)))).count
        let digitsKmh = String(speedInKmh.formatted(.number.precision(.fractionLength(0)))).count
        
        // Example: 36.0 m/s vs 115.2 km/h (which ist the number with the greatest possible length).
        // Assume the width of the decimal point (or comma) in the font is 0.8 relative to the width of the numbers in this font, then
        // Ratio of the widths (the scale factor) is: (2 + 0,8 + 1) / (3 + 0.8 + 1)
        let relativewidthOfDecimalPoint = 0.2 // (assuemd) width of the decimal point (or comma) compared to with of a digit of the monospaced font.
        let ratio = (Double(digits) + 1.0 + relativewidthOfDecimalPoint) / (Double(digitsKmh) + 1.0 + relativewidthOfDecimalPoint) * 0.9 // with one fraction digit

        print("Geschwindigkeit in km/h: \(speedInKmh), digits: \(digitsKmh), in Einheit \(speed), digits: \(digits), ratio: \(ratio).")

        return ratio
    }
    
    var body: some View {
        VStack {

            Text("Uwes Tacho")
                .font(.largeTitle)
                .padding(.top)

            Divider()

            SpeedView(unitSpeed: mainUnitSpeed, location: locationsHandler.lastLocation)
                .rotation3DEffect(Angle(degrees: rotationAngleForAnimation), axis: /*@START_MENU_TOKEN@*/(x: 0.0, y: 1.0, z: 0.0)/*@END_MENU_TOKEN@*/ )
                .animation(.linear(duration: 0.1).delay(animationDuration), value: useAnimation) // change value while at 90 degrees and thus not visible
                .foregroundColor(locationsHandler.updatesStarted ? .primary : .secondary) //gray out speed values, when not updating.


            GeometryReader() { geo in
                
                if self.isLandscape {
                
                    Grid() {
                        Divider()
                        GridRow() {

                            SpeedView2(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .kilometersPerHour))
                                .frame(width: geo.size.width / 4, height: geo.size.height)
                                .onTapGesture { changeMainUnitSpeedAnimated(.kilometersPerHour) }
                            SpeedView2(unitSpeed: .milesPerHour, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .milesPerHour))
                                .frame(width: geo.size.width / 4, height: geo.size.height)
                                .onTapGesture { changeMainUnitSpeedAnimated(.milesPerHour) }
                            SpeedView2(unitSpeed: .knots, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .knots))
                                .frame(width: geo.size.width / 4, height: geo.size.height)
                                .onTapGesture { changeMainUnitSpeedAnimated(.knots) }
                            SpeedView2(unitSpeed: .metersPerSecond, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .metersPerSecond))
                                .frame(width: geo.size.width / 4, height: geo.size.height)
                                .onTapGesture { changeMainUnitSpeedAnimated(.metersPerSecond) }
                        }
                    }
//                    .frame(width: geo.size.width, height: geo.size.height)

                } else {
                    Grid() {
                        Divider()
                        Spacer()

                        GridRow() {
                            SpeedView2(unitSpeed: .kilometersPerHour, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .kilometersPerHour))
                                .frame(width: geo.size.width / 2, height: geo.size.height * 0.4)
                                .onTapGesture { changeMainUnitSpeedAnimated(.kilometersPerHour) }
                            SpeedView2(unitSpeed: .milesPerHour, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .milesPerHour))
                                .frame(width: geo.size.width / 2, height: geo.size.height * 0.4)
                                .onTapGesture { changeMainUnitSpeedAnimated(.milesPerHour) }
                        }
                        GridRow() {
                            SpeedView2(unitSpeed: .knots, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .knots))
                                .frame(width: geo.size.width / 2, height: geo.size.height * 0.4)
                                .onTapGesture { changeMainUnitSpeedAnimated(.knots) }
                            SpeedView2(unitSpeed: .metersPerSecond, location: locationsHandler.lastLocation, ratio: ratioLengthToMaxNumber(location: locationsHandler.lastLocation, unit: .metersPerSecond))
                                .frame(width: geo.size.width / 2, height: geo.size.height * 0.4)
                                .onTapGesture { changeMainUnitSpeedAnimated(.metersPerSecond) }
                        }
                        Spacer()
                    }
//                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .foregroundColor(locationsHandler.updatesStarted ? .primary : .secondary) //gray out speed values, when not updating.

            Divider()
            Spacer()
            
            HStack() {

                Text("# \(self.locationsHandler.count)")
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
                Text("# \(self.locationsHandler.count)")
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
        // a timer is used additionally, that fires after four seconds to assess the state and show the respective
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
