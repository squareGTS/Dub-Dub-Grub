//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 21.12.2022.
//

import SwiftUI

struct LocationListView: View {
    @EnvironmentObject private var locationMananger: LocationManager
    @StateObject private var viewModel = LocationListViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationMananger.locations) { location in
                    NavigationLink(destination: viewModel.createLocationDetailView(for: location, in: dynamicTypeSize)) {
                        LocationCell(location: location, profiles: viewModel.checkedInProfiles[location.id, default: []])
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                    }
                }
            }
            .navigationTitle("Grub Spots")
            .onAppear { viewModel.getCheckedInProfilesDictionary() }
            .alert(item: $viewModel.alertItem) { $0.alert }
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}
