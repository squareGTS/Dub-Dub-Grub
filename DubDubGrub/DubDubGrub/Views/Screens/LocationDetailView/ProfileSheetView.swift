//
//  ProfileSheetView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 11.01.2023.
//

import SwiftUI

// Alternative Profile Modal View for large dynamic type size
// We present this as a shhet instead of a small pop up

struct ProfileSheetView: View {
    var profile: DDGProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(uiImage: profile.avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                    .accessibilityHidden(true)
                
                Text(profile.firstName + " " + profile.lastName)
                    .bold()
                    .font(.title2)
                    .minimumScaleFactor(0.9)
                
                Text(profile.companyName)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.9)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(Text("Works at \(profile.companyName)"))
                
                Text(profile.bio)
                    .accessibilityLabel(Text("Bio, \(profile.bio)"))
            }
            .padding()
        }
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheetView(profile: DDGProfile(record: MockData.profile))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
}
