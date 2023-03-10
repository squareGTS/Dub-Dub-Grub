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

@MainActor final class LocationDetailViewModel: ObservableObject {
    @Published var checkedInProfiles: [DDGProfile] = []
    @Published var isShowingProfileModal = false
    @Published var isShowingProfileSheet = false
    @Published var isCheckedIn = false
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    var location: DDGLocation
    var selectedProfile: DDGProfile?
    var buttonColor: Color { isCheckedIn ? .grubRed : .brandPrimary }
    var buttonImageTitle: String { isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark" }
    var buttonA11yLabel: String { isCheckedIn ? "Check out of location" : "Check in to location" }
    
    init(location: DDGLocation) {
        self.location = location
    }
    
    func determinColumns(for dynamicType: DynamicTypeSize) -> [GridItem] {
        let numberOfColumns = dynamicType >= .accessibility3 ? 1 : 3
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
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
    
    func getCheckedInStatus() {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
        
        Task {
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                    self.isCheckedIn = reference.recordID == self.location.id
                } else {
                    self.isCheckedIn = false
                }
            } catch {
                alertItem = AlertContext.unableToGetCheckInStatus
            }
        }
        
        //        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
        //            DispatchQueue.main.async {
        //                switch result {
        //                case .success(let record):
        //                    if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
        //                        self.isCheckedIn = reference.recordID == self.location.id
        //                    } else {
        //                        self.isCheckedIn = false
        //                    }
        //
        //                case .failure(_):
        //                    self.alertItem = AlertContext.unableToGetCheckInStatus
        //                }
        //            }
        //        }
    }
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus) {
        // Retrive the DDGProfile
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.unableToGetProfile
            return
        }
        
        showLoadingView()
        
        Task {
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                // create a reference to the location
                switch checkInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                case .checkedOut:
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                }
                
                let savedRecord = try await CloudKitManager.shared.save(record: record)
                
                HapticManager.playSuccess()
                let profile = DDGProfile(record: savedRecord)
                switch checkInStatus {
                case .checkedIn:
                    // update our checkInProfiles array
                    checkedInProfiles.append(profile)
                case .checkedOut:
                    checkedInProfiles.removeAll { $0.id == profile.id }
                }
                
                isCheckedIn.toggle()
                
                print("??? Checked In/Out Successfuly")
                hideLoadingView()
            } catch {
                hideLoadingView()
                alertItem = AlertContext.unableToCheckInOrOut
            }
        }
        
        
        
        
        
        
        
        //        CloudKitManager.shared.fetchRecord(with: profilerecordID) { [self] result in
        //            switch result {
        //            case .success(let record):
        //                // create a reference to the location
        //                switch checkInStatus {
        //                case .checkedIn:
        //                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
        //                    record[DDGProfile.kIsCheckedInNilCheck] = 1
        //                case .checkedOut:
        //                    record[DDGProfile.kIsCheckedIn] = nil
        //                    record[DDGProfile.kIsCheckedInNilCheck] = nil
        //                }
        //
        //                // Save the uploaded profile to CloudKit
        //                CloudKitManager.shared.save(record: record) { result in
        //                    DispatchQueue.main.async { [self] in
        //                        hideLoadingView()
        //                        switch result {
        //                        case .success(let record):
        //                            HapticManager.playSuccess()
        //                            let profile = DDGProfile(record: record)
        //
        //                            switch checkInStatus {
        //                            case .checkedIn:
        //                                // update our checkInProfiles array
        //                                checkedInProfiles.append(profile)
        //                            case .checkedOut:
        //                                checkedInProfiles.removeAll { $0.id == profile.id }
        //                            }
        //
        //                            isCheckedIn.toggle()
        //
        //                            print("??? Checked In/Out Successfuly")
        //                        case .failure(_):
        //                            hideLoadingView()
        //                            alertItem = AlertContext.unableToCheckInOrOut
        //                        }
        //                    }
        //                }
        //            case .failure(_):
        //                alertItem = AlertContext.unableToCheckInOrOut
        //            }
        //        }
    }
    
    func getCheckedInProfile() {
        showLoadingView()
        //        CloudKitManager.shared.getCheckedInProfiles(for: location.id) { [self] result in
        //            DispatchQueue.main.async {
        //                switch result {
        //                case .success(let profiles):
        //                    self.checkedInProfiles = profiles
        //                case .failure(_):
        //                    self.alertItem = AlertContext.unableToGetCheckedInProfiles
        //                }
        //                self.hideLoadingView()
        //            }
        //        }
        
        Task {
            do {
                checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfiles(for: location.id)
                hideLoadingView()
            } catch {
                hideLoadingView()
                alertItem = AlertContext.unableToGetCheckedInProfiles
            }
        }
    }
    
    func show(_ profile: DDGProfile, in dynamicTypeSize: DynamicTypeSize) {
        selectedProfile = profile
        if dynamicTypeSize >= .accessibility3 {
            isShowingProfileSheet = true
        } else {
            isShowingProfileModal = true
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
