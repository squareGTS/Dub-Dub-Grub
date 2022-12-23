//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import MapKit

final class LocationMapViewModel: ObservableObject {
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @Published var locations: [DDGLocation] = []
    
    func getLocations() {
        CloudKitManager.getLocations { result in
            switch result {
                
            case .success(let locations):
                self.locations = locations
//                print(locations)
            case .failure(_):
                self.alertItem = AlertContext.unableToGetLocations
            }
        }
    }
}
