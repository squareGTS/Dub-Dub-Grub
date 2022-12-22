//
//  View+Ext.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 22.12.2022.
//

import SwiftUI

extension View {
    func profileNameStyle() -> some View {
        self.modifier(ProfileNameText())
    }
}
