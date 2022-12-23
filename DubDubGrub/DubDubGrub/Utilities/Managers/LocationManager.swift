//
//  LocationManager.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import Foundation

final class LocationManager: ObservableObject {
    @Published var locations: [DDGLocation] = []
}
