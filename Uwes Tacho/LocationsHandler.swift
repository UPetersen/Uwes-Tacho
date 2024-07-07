//
//  LocationsHandler.swift
//  Uwes Tacho
//
//  Created by Uwe Petersen on 05.06.24.
//

import Foundation


import os
//import SwiftUI
import CoreLocation

@MainActor class LocationsHandler: ObservableObject {
//    let logger = Logger(subsystem: "com.UNPP.Uwes-Tacho", category: "LocationsHandler")
    
    static let shared = LocationsHandler()  // Create a single, shared instance of the object.

    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?

    @Published var lastLocation = CLLocation()
    @Published var count = 0
    @Published var isStationary = false

    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }
    
//    @Published
//    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
//        didSet {
//            backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
//            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
//        }
//    }
    
    private init() {
        self.manager = CLLocationManager()  // Creating a location manager instance is safe to call here in `MainActor`.
    }
    
    func startLocationUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
//        self.logger.info("Starting location updates")
        print("Starting location updates")
        Task() {
            do {
                self.updatesStarted = true
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !self.updatesStarted { break }  // End location updates by breaking out of the loop.
                    if let loc = update.location {
                        self.lastLocation = loc
                        self.isStationary = update.isStationary
                        self.count += 1
//                        self.logger.info("Location \(self.count): \(self.lastLocation)")
                    }
                }
            } catch {
//                self.logger.error("Could not start location updates")
                print("Could not start location updates")
            }
            return
        }
    }
    
    func stopLocationUpdates() {
//        self.logger.info("Stopping location updates")
        print("Stopping location updates")
        self.updatesStarted = false
    }
}

