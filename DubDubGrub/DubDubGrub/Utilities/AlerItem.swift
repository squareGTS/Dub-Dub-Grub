//
//  AlerItem.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    
    //MARK: - MapView Errors
    static let unableToGetLocations = AlertItem(title: Text("Locations Error"),
                                                message: Text("Unable to retrive locations at this time. \nPlease try again."),
                                                dismissButton: .default(Text("Ok")))
}
