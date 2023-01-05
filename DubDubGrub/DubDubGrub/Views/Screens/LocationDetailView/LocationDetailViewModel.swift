//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 28.12.2022.
//

import SwiftUI
import MapKit
import CloudKit

enum CheckInStatus {
    case checkedIn, checkedOut
}

final class LocationDetailViewModel: ObservableObject {
    
    @Published var alertItem: AlertItem?
    @Published var isShowingProfileModel = false
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var location: DDGLocation
    
    init(location: DDGLocation) {
        self.location = location
    }
    
    func getDirectionsToLocation() {
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        
    }
    
    func callLocation() {
        guard let url = URL(string: "tel://\(location.phoneNumber)") else {
            alertItem = AlertContext.invalidPhoneNumber
            return
        }
        UIApplication.shared.open(url)
    }
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus) {
        // Retrive the DDGProfile
        guard let profilerecordID = CloudKitManager.shared.profileRecordID else {
            // show an allert
            return
        }
        CloudKitManager.shared.fetchRecord(with: profilerecordID) { [self] result in
            switch result {
            case .success(let record):
                // create a reference to the location
                
                switch checkInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckIn] = CKRecord.Reference(recordID: location.id, action: .none)
                case .checkedOut:
                    record[DDGProfile.kIsCheckIn] = nil
                }
                
                // Save the uploaded profile to CloudKit
                CloudKitManager.shared.save(record: record) { result in
                    switch result {
                    case .success(_):
                        // update our checkInProfiles array
                        print("✅ Checked In/Out Successfuly")
                    case .failure(_):
                        print("❌ Error saving record")
                    }
                }
            case .failure(_):
                print("❌ Error fatching record")
            }
        }
    }
}
