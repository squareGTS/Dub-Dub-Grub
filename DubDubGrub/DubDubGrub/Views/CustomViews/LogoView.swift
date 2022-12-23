//
//  LogoView.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import SwiftUI

struct LogoView: View {
    var frameWidth: CGFloat
    
    var body: some View {
        Image("ddg-map-logo")
            .resizable()
            .scaledToFit()
            .frame(width: frameWidth)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(frameWidth: 250)
    }
}
