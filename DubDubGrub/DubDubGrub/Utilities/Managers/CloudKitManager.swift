//
//  CloudKitManager.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import CloudKit

final class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    private init() {}
    
    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?
    let container = CKContainer.default()
    
    //    func getUserRecord() {
    //        // Get our UserRecordID from the container
    //        CKContainer.default().fetchUserRecordID { recordID, error in
    //            guard let recordID = recordID, error == nil else {
    //                print(error!.localizedDescription)
    //                return
    //            }
    //
    //            // Get UserRecord from the Public Database
    //            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
    //                guard let userRecord = userRecord, error == nil else {
    //                    print(error!.localizedDescription)
    //                    return
    //                }
    //                self.userRecord = userRecord
    //
    //                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
    //                    self.profileRecordID = profileReference.recordID
    //                }
    //            }
    //        }
    //    }
    
    func getUserRecord() async throws {
        // Get our UserRecordID from the container
        let recordID = try await container.userRecordID()
        // Get UserRecord from the Public Database
        let record = try await container.publicCloudDatabase.record(for: recordID)
        
        userRecord = record
        
        if let profileReference = record["userProfile"] as? CKRecord.Reference {
            profileRecordID = profileReference.recordID
        }
    }
    
    //    func getLocations(completed: @escaping (Result<[DDGLocation], Error>) -> ()) {
    //        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
    //        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
    //        query.sortDescriptors = [sortDescriptor]
    //
    //        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
    //            guard let records = records, error == nil else {
    //                completed(.failure(error!))
    //                return
    //            }
    //
    //            //            var locations: [DDGLocation] = []
    //            //
    //            //            for record in records {
    //            //                let location = DDGLocation(record: record)
    //            //                locations.append(location)
    //            //            }
    //
    //            let locations = records.map(DDGLocation.init)
    //            completed(.success(locations))
    //        }
    //    }
    
    func getLocations() async throws -> [DDGLocation] {
        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        return records.map(DDGLocation.init)
    }
    
    //    func getCheckedInProfiles(for locationID: CKRecord.ID, completed: @escaping (Result<[DDGProfile], Error>) -> Void) {
    //        let reference = CKRecord.Reference(recordID: locationID, action: .none)
    //        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
    //        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
    //
    //        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
    //            guard let records = records, error == nil else {
    //                completed(.failure(error!))
    //                return
    //            }
    //
    //            let profiles = records.map(DDGProfile.init)
    //            completed(.success(profiles))
    //        }
    //    }
    
    func getCheckedInProfiles(for locationID: CKRecord.ID) async throws -> [DDGProfile] {
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        return records.map(DDGProfile.init)
    }
    
    func getCheckedInProfilesDictionary() async throws -> [CKRecord.ID : [DDGProfile]] {
        print("✅ Network call fired off")
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
        
        let (matchResults, cursor) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        for record in records {
            // Build our dictionary
            let profile = DDGProfile(record: record)
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }
        
        print("1️⃣ checkedInProfiles = \(checkedInProfiles)")
        guard let cursor = cursor else { return checkedInProfiles }
        
        do {
            return try await continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles)
        } catch {
            throw error
        }
    }
    
    private func continueWithCheckedInProfilesDict(cursor: CKQueryOperation.Cursor,
                                                   dictionary: [CKRecord.ID : [DDGProfile]]) async throws -> [CKRecord.ID : [DDGProfile]] {
        
        var checkedInProfiles = dictionary
        
        let (matchResults, cursor) = try await container.publicCloudDatabase.records(continuingMatchFrom: cursor)
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        for record in records {
            // Build our dictionary
            let profile = DDGProfile(record: record)
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }
        
        print("⭕️ checkedInProfiles = \(checkedInProfiles)")
        guard let cursor = cursor else { return checkedInProfiles }
        
        do {
            return try await continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles)
        } catch {
            throw error
        }
    }
    
    func getCheckedInProfilesCount() async throws -> [CKRecord.ID : Int] {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        var checkedInProfiles: [CKRecord.ID : Int] = [:]
        
        let (matchResults, cursor) = try await container.publicCloudDatabase.records(matching: query,
                                                                                     desiredKeys: [DDGProfile.kIsCheckedIn])
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        for record in records {
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            
            if let count = checkedInProfiles[locationReference.recordID] {
                checkedInProfiles[locationReference.recordID] = count + 1
            } else {
                checkedInProfiles[locationReference.recordID] = 1
            }
        }
        return checkedInProfiles
    }
    
    func batchSave(records: [CKRecord]) async throws -> [CKRecord] {
        let (saveResult, _) = try await container.publicCloudDatabase.modifyRecords(saving: records, deleting: [])
        return saveResult.compactMap { _, result in try? result.get() }
    }
    
    func save(record: CKRecord) async throws -> CKRecord {
        return try await container.publicCloudDatabase.save(record)
    }
    
    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        return try await container.publicCloudDatabase.record(for: id)
    }
}
