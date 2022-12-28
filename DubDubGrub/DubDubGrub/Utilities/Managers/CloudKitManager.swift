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
    
    func getUserRecord() {
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
                self.userRecord = userRecord
            }
        }
    }
    
    func getLocations(completed: @escaping (Result<[DDGLocation], Error>) -> ()) {
        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            guard let records = records else { return }
            
            //            var locations: [DDGLocation] = []
            //
            //            for record in records {
            //                let location = DDGLocation(record: record)
            //                locations.append(location)
            //            }
            
            let locations = records.map { $0.convertToDDGLocation() }
            
            completed(.success(locations))
        }
    }
    
    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) -> ()) {
        
        //Create a CKOperation to save our User and Profile Records
        let operation = CKModifyRecordsOperation(recordsToSave: records)
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            guard let savedRecords = savedRecords, error == nil else {
                completed(.failure(error!))
                return
            }
            completed(.success(savedRecords))
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func save(record: CKRecord, completed: @escaping (Result<CKRecord, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.save(record) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                return
            }
            completed(.success(record))
        }
    }
    
    func fetchRecord(with id: CKRecord.ID, completed: @escaping (Result<CKRecord, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                return
            }
            completed(.success(record))
        }
    }
}
