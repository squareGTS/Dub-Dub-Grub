//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 27.12.2022.
//

import CloudKit

enum ProfileContext {
    case create, update
}

extension ProfileView {
    
    @MainActor final class ProfileViewModel: ObservableObject {
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var companyName = ""
        @Published var bio = ""
        @Published var avatar = PlaceholderImage.avatar
        @Published var isShowingPhotoPicker = false
        @Published var isLoading = false
        @Published var isCheckedIn = false
        @Published var alertItem: AlertItem?
        
        private var existingProfileRecord: CKRecord? {
            didSet { profileContext = .update }
        }
        
        var profileContext: ProfileContext = .create
        var buttonTitle: String { profileContext == .create ? "Create Profile" : "Update Profile" }
        
        func isValidProfile() -> Bool {
            guard !firstName.isEmpty,
                  !lastName.isEmpty,
                  !companyName.isEmpty,
                  !bio.isEmpty,
                  avatar != PlaceholderImage.avatar,
                  bio.count <= 100 else { return false }
            return true
        }
        
        func getCheckedInStatus() {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        self.isCheckedIn = true
                    } else {
                        self.isCheckedIn = false
                    }
                } catch {
                    print("Unable to get checked in status.")
                }
            }
            
            //            CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            //                DispatchQueue.main.async {
            //                    switch result {
            //                    case .success(let record):
            //                        if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
            //                            self.isCheckedIn = true
            //                        } else {
            //                            self.isCheckedIn = false
            //                        }
            //
            //                    case .failure(_):
            //                        break
            //                    }
            //                }
            //            }
        }
        
        func checkOut() {
            guard let profileID  = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.unableToGetProfile
                return
            }
            
            showLoadingView()
            
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileID)
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    
                    let _ = try await CloudKitManager.shared.save(record: record)
                    HapticManager.playSuccess()
                    isCheckedIn = false
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToCheckInOrOut
                }
            }
            
            //            CloudKitManager.shared.fetchRecord(with: profileID) { result in
            //
            //                switch result {
            //                case .success(let record):
            //                    record[DDGProfile.kIsCheckedIn] = nil
            //                    record[DDGProfile.kIsCheckedInNilCheck] = nil
            //
            //                    CloudKitManager.shared.save(record: record) { [self] result in
            //                        hideLoadingView()
            //                        DispatchQueue.main.async {
            //                            switch result {
            //                            case .success(_):
            //                                HapticManager.playSuccess()
            //                                self.isCheckedIn = false
            //                            case .failure(_):
            //                                self.alertItem = AlertContext.unableToCheckInOrOut
            //                            }
            //                        }
            //                    }
            //
            //                case .failure(_):
            //                    self.hideLoadingView()
            //                    DispatchQueue.main.async { self.alertItem = AlertContext.unableToCheckInOrOut }
            //                }
            //            }
        }
        
        func determineButtonAction() {
            profileContext == .create ? createProfile() : updateProfile()
        }
        
        private func createProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            //create our CKrecord from the profile view
            let profileRecord = createProfileRecord()
            
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            //Create reference on UserRecord to the DDGProfile we created
            userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
            
            showLoadingView()
            
            Task {
                do {
                    let records = try await CloudKitManager.shared.batchSave(records: [userRecord, profileRecord])
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    hideLoadingView()
                    alertItem = AlertContext.createProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.createProfileFailure
                }
            }
            
            //            CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
            //                DispatchQueue.main.async {
            //                    self.hideLoadingView()
            //                    switch result {
            //                    case .success(let records):
            //                        for record in records where record.recordType == RecordType.profile {
            //                            self.existingProfileRecord = record
            //                            CloudKitManager.shared.profileRecordID = record.recordID
            //                        }
            //                        self.alertItem = AlertContext.createProfileSuccess
            //                        break
            //
            //                    case .failure(_):
            //                        self.alertItem = AlertContext.createProfileFailure
            //                        break
            //                    }
            //                }
            //            }
        }
        
        func getProfile() {
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
            let profileRecordID = profileReference.recordID
            
            showLoadingView()
            
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    existingProfileRecord = record
                                           let profile = DDGProfile(record: record)
                                           firstName = profile.firstName
                                           lastName = profile.lastName
                                           companyName = profile.companyName
                                           bio = profile.bio
                                           avatar = profile.avatarImage
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToGetProfile
                }
            }
            
//            CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
//                DispatchQueue.main.async { [self] in
//                    hideLoadingView()
//                    switch result {
//                    case .success(let record):
//                        existingProfileRecord = record
//                        let profile = DDGProfile(record: record)
//                        firstName = profile.firstName
//                        lastName = profile.lastName
//                        companyName = profile.companyName
//                        bio = profile.bio
//                        avatar = profile.avatarImage
//
//                    case .failure(_):
//                        self.alertItem = AlertContext.unableToGetProfile
//                        break
//                    }
//                }
//            }
        }
        
        private func updateProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            guard let profileRecord = existingProfileRecord else {
                alertItem = AlertContext.unableToGetProfile
                return
            }
            
            profileRecord[DDGProfile.kFirstName] = firstName
            profileRecord[DDGProfile.kLastName] = lastName
            profileRecord[DDGProfile.kCompanyName] = companyName
            profileRecord[DDGProfile.kBio] = bio
            profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()
            
            showLoadingView()
            
            Task {
                do {
                    let _ = try await CloudKitManager.shared.save(record: profileRecord)
                    hideLoadingView()
                    alertItem = AlertContext.updateProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.updateProfileFailure
                }
            }
            
//            CloudKitManager.shared.save(record: profileRecord) { result in
//                DispatchQueue.main.async { [self] in
//                    hideLoadingView()
//                    switch result {
//                    case .success(_):
//                        self.alertItem = AlertContext.updateProfileSuccess
//                    case .failure(_):
//                        self.alertItem = AlertContext.updateProfileFailure
//                    }
//                }
//            }
        }
        
        private func createProfileRecord() -> CKRecord {
            let profileRecord = CKRecord(recordType: RecordType.profile)
            profileRecord[DDGProfile.kFirstName] = firstName
            profileRecord[DDGProfile.kLastName] = lastName
            profileRecord[DDGProfile.kCompanyName] = companyName
            profileRecord[DDGProfile.kBio] = bio
            profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()
            return profileRecord
        }
        
        private func showLoadingView() { isLoading = true }
        private func hideLoadingView() { isLoading = false }
    }
}
