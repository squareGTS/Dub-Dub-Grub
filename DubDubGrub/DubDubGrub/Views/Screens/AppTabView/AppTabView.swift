//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 21.12.2022.
//

import SwiftUI

struct AppTabView: View {
    @StateObject private var viewModel = AppTabViewModel()
    
    var body: some View {
        TabView {
            LocationMapView()
                .tabItem { Label("Map", systemImage: "map") }
            LocationListView()
                .tabItem { Label("Locations", systemImage: "building") }
            NavigationView{
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
        .onAppear {
            CloudKitManager.shared.getUserRecord()
            viewModel.checkIfHasSeenOnboarding()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView) {
            OnboardView()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
