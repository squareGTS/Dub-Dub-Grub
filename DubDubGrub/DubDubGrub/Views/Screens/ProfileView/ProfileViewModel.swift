//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 27.12.2022.
//

import CloudKit

final class ProfileViewModel: ObservableObject {
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var companyName = ""
    @Published var bio = ""
    @Published var avatar = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var alertItem: AlertItem?
    
    func isValidProfile() -> Bool {
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count < 100 else { return false }
        return true
    }
    
    func getProfile() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                let profileReference = userRecord["userProfile"] as! CKRecord.Reference
                let recordRecordID = profileReference.recordID
                
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordRecordID) { profileRecord, error in
                    guard let profileRecord = profileRecord, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async { [self] in
                        let profile = DDGProfile(record: profileRecord)
                        firstName = profile.firstName
                        lastName = profile.lastName
                        companyName = profile.companyName
                        bio = profile.bio
                        avatar = profile.createAvatarImage()
                    }
                }
            }
        }
    }
    
    func createProfile() {
        guard isValidProfile() else {
            alertItem = AlertContext.invalidProfile
            return
        }
        //create our CKrecord from the profile view
        let profileRecord = createProfileRecord()
        
        // Get our UserRecordID from the container
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            // Get UserRecord from the Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                //Create reference on UserRecord to the DDGProfile we created
                userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
                
                //Create a CKOperation to save our User and Profile Records
                let operation = CKModifyRecordsOperation(recordsToSave: [userRecord, profileRecord])
                operation.modifyRecordsCompletionBlock = { saveRecords, _, error in
                    guard let saveRecords = saveRecords, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    print(saveRecords)
                }
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
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
}
