//
//  SpeedView.swift
//  LiveUpdatesSample
//
//  Created by Uwe Petersen on 04.06.24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import CoreLocation


struct LargeText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .monospacedDigit()
            .font(.system(size: 100))
            .minimumScaleFactor(0.1) // Allows that text is shrunk to completely fill out the bounding box
            .lineLimit(1)
    }
}

struct UnitText: ViewModifier {
    @State private var isLandscape = false

    func body(content: Content) -> some View {
        content
            .monospacedDigit()
            .font(isLandscape  ? .title3 : .title) // maybe not needed any more
            .minimumScaleFactor(0.1) // Allows that text is shrunk to completely fill out the bounding box
            .lineLimit(1)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
                self.isLandscape = scene.interfaceOrientation.isLandscape
            }
    }
}

extension View {
    func unitText() -> some View {
        modifier(UnitText())
    }
}
extension View {
    func largeText() -> some View {
        modifier(LargeText())
    }
}



struct SpeedView: View {
    
    var unitSpeed: UnitSpeed
    var location: CLLocation
    
    var body: some View {
        VStack() {
            Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).speed)
                .largeText()

            HStack(alignment: .firstTextBaseline ) {
                Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).accuracy)
                Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).unit)
            }
            .unitText()
        }
        .padding(.horizontal)
    }
}

struct SpeedView2: View {
    
    var unitSpeed: UnitSpeed
    var location: CLLocation
    // ratio ensures that e.g. 120,0 and 97,0 are printed with the same font size, since the widths of the text boxes are adjusted accordingly via ratio
    var ratio: Double
    
    var body: some View {
        
        GeometryReader() { geo in
            VStack() {
                Spacer()
                HStack {
                    Spacer()
                    Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).speed)
                        .frame(width: geo.size.width * ratio, height: geo.size.height * 0.4, alignment: .center)
                        .largeText()
//                        .background(Color.gray)
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline ) {
                    Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).accuracy)
//                        .background((Color.yellow))
                    Text(speedStringForUnit(location: location, unitSpeed: unitSpeed).unit)
//                        .background(Color.green)
                }
                .frame(width: geo.size.width, height: geo.size.height * 0.2)
                .unitText()
                Spacer()
            }
        }
//        .background(Color.red)
        .padding(.horizontal)
    }
}
    


func speedStringForUnit(location: CLLocation, unitSpeed: UnitSpeed) -> (speed: String, accuracy: String, unit: String) {
    let speed         = Measurement<UnitSpeed>(value: location.speed, unit: .metersPerSecond).converted(to: unitSpeed)
    let speedAccuracy = Measurement<UnitSpeed>(value: location.speedAccuracy, unit: .metersPerSecond).converted(to: unitSpeed)
    //        print("\(speed.value.formatted(.number.precision(.fractionLength(1))))" +  "±\(speedAccuracy.value.formatted(.number.precision(.fractionLength(2))))" + speed.unit.symbol )
    if location.speedAccuracy >= 0 {
        return ("\(speed.value.formatted(.number.precision(.fractionLength(1))))",
                "±\(speedAccuracy.value.formatted(.number.precision(.fractionLength(2))))",
                speed.unit.symbol )
    } else {
        return ("---", "---", speed.unit.symbol)
    }
}



//#Preview {
//    SpeedView()
//}
