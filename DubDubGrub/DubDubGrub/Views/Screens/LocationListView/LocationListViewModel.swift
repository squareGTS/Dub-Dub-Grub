//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 09.01.2023.
//

import CloudKit
import SwiftUI

extension LocationListView {
    
    @MainActor final class LocationListViewModel: ObservableObject {
        @Published var checkedInProfiles: [CKRecord.ID: [DDGProfile]] = [:]
        @Published var alertItem: AlertItem?
        
        func getCheckedInProfilesDictionary() async {
            //            CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            //                DispatchQueue.main.async { [self] in
            //                    switch result {
            //                    case .success(let checkedInProfiles):
            //                        self.checkedInProfiles = checkedInProfiles
            //                    case .failure(_):
            //                        alertItem = AlertContext.unableToGetAllCheckedInProfiles
            //                    }
            //                }
            //            }
            
            do {
                checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfilesDictionary()
            } catch {
                alertItem = AlertContext.unableToGetAllCheckedInProfiles
            }
        }
        
        func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: []].count
            let personPlurality = count == 1 ? "person" : "people"
            
            return "\(location.name) \(count) \(personPlurality) checked in."
        }
        
        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
            if dynamicTypeSize >= .accessibility3 {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
            }
        }
    }
}
