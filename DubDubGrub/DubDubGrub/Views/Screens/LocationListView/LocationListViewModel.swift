//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 09.01.2023.
//

import CloudKit

final class LocationListViewModel: ObservableObject {
    @Published var checkedInProfiles: [CKRecord.ID: [DDGProfile]] = [:]
    
    func getCheckedInProfilesDictionary() {
        CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                    print("Error getting back disctionary")
                }
            }
        }
    }
}
