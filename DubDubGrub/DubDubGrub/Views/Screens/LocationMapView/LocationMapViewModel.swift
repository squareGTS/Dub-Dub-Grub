//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import CloudKit
import MapKit
import SwiftUI

final class LocationMapViewModel: ObservableObject {
    @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
    @Published var isShowingDetailView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
 
    func getLocations(for locationManager: LocationManager) {
        CloudKitManager.shared.getLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    locationManager.locations = locations
                case .failure(_):
                    self.alertItem = AlertContext.unableToGetLocations
                }
            }
        }
    }
    
    func getCheckedInCounts() {
        CloudKitManager.shared.getCheckedInProfilesCount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                    //show alert
                    break
                }
            }
        }
    }
    
    @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
        if dynamicTypeSize >= .accessibility3 {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
}
