//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 21.12.2022.
//

import SwiftUI

struct LocationListView: View {
    
    @EnvironmentObject private var locationMananger: LocationManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationMananger.locations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationCell(location: location)
                    }
                }
            }
            .navigationTitle("Grub Spots")
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}
