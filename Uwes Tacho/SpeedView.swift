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
            .minimumScaleFactor(0.1)
            .lineLimit(1)
    }
}

extension View {
    func largeText() -> some View {
        modifier(LargeText())
    }
}


struct UnitText: ViewModifier {
    @State private var isLandscape = false

    func body(content: Content) -> some View {
        content
            .monospacedDigit()
            .font(isLandscape  ? .title3 : .title)
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


struct SpeedView: View {
    
    var unitSpeed: UnitSpeed
    var location: CLLocation
    
    var body: some View {
        VStack() {
            Text(speed(unitSpeed).speed)
                .largeText()

            HStack(alignment: .firstTextBaseline ) {
                Text(speed(unitSpeed).accuracy)
                Text(speed(unitSpeed).unit)
            }
            .unitText()
        }
    }
    
    func speed(_ unitSpeed: UnitSpeed) -> (speed: String, accuracy: String, unit: String) {
        let speed         = Measurement<UnitSpeed>(value: self.location.speed, unit: .metersPerSecond).converted(to: unitSpeed)
        let speedAccuracy = Measurement<UnitSpeed>(value: self.location.speedAccuracy, unit: .metersPerSecond).converted(to: unitSpeed)
        print("hugo")
        print("\(speed.value.formatted(.number.precision(.fractionLength(1))))" +  "±\(speedAccuracy.value.formatted(.number.precision(.fractionLength(2))))" + speed.unit.symbol )
        if location.speedAccuracy >= 0 {
            return ("\(speed.value.formatted(.number.precision(.fractionLength(1))))",
                    "±\(speedAccuracy.value.formatted(.number.precision(.fractionLength(2))))",
                    speed.unit.symbol )
        } else {
            return ("---", "---", speed.unit.symbol)
        }
    }

}

//#Preview {
//    SpeedView()
//}
