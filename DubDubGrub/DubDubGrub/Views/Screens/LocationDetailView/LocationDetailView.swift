//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 22.12.2022.
//

import SwiftUI

struct LocationDetailView: View {
    @ObservedObject var viewModel: LocationDetailViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                BannerImageView(image: viewModel.location.createBannerImage())
                
                HStack {
                    AdressView(adress: viewModel.location.address)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                DescriptionView(text: viewModel.location.description)
                
                ZStack {
                    Capsule()
                        .frame(height: 80)
                        .foregroundColor(Color(.secondarySystemBackground))
                    
                    HStack(spacing: 20) {
                        Button {
                            viewModel.getDirectionsToLocation()
                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "location.fill")
                        }
                        Link(destination: URL(string: viewModel.location.websiteURL)!, label: {
                            LocationActionButton(color: .brandPrimary, imageName: "network")
                        })
                        
                        Button {
                            viewModel.callLocation()
                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "phone.fill")
                        }
                        if let _ = CloudKitManager.shared.profileRecordID {
                            Button {
                                viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkedOut : .checkedIn)
                                playHaptic()
                            } label: {
                                LocationActionButton(color: viewModel.isCheckedIn ? .grubRed : .brandPrimary,
                                                     imageName: viewModel.isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Text("Who's Here?")
                    .bold()
                    .font(.title2)
                
                ZStack {
                    if viewModel.checkedInProfiles.isEmpty {
                        //empty state
                        
                        Text("Nobody's Here 😔")
                            .bold()
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: viewModel.columns, content: {
                                
                                ForEach(viewModel.checkedInProfiles) { profile in
                                    FirstNameAvstsrName(profile: profile)
                                        .onTapGesture {
                                            viewModel.isShowingProfileModel = true
                                        }
                                }
                            })
                        }
                    }
                    if viewModel.isLoading { LoadingView() }
                }
                Spacer()
            }
            
            if viewModel.isShowingProfileModel {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .opacity(0.9)
                //                    .transition(.opacity)
                    .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.35)))
                //  .animation(.easeOut)
                    .zIndex(1)
                ProfileModalView(isShowingProfileModal: $viewModel.isShowingProfileModel,
                                 profile: DDGProfile(record: MockData.profile))
                .transition(.opacity.combined(with: .slide))
                .animation(.easeOut)
                .zIndex(2)
            }
        }
        .onAppear {
            viewModel.getCheckedInProfile()
            viewModel.getCheckedInStatus()
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location: DDGLocation(record: MockData.location)))
        }
    }
}

struct LocationActionButton: View {
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFill()
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
        }
    }
}

struct FirstNameAvstsrName: View {
    var profile: DDGProfile
    
    var body: some View {
        VStack {
            AvatarView(image: profile.createAvatarImage(), size: 64)
            
            Text(profile.firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BannerImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
    }
}

struct AdressView: View {
    var adress: String
    
    var body: some View {
        Label(adress, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct DescriptionView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .frame(height: 70)
            .padding(.horizontal)
    }
}
