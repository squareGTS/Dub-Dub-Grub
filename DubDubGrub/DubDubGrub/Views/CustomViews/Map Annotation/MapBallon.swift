//
//  MapBallon.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 10.01.2023.
//

import SwiftUI

struct MapBallon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.minY))
        
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        
        
        return path
    }
}

struct MapBallon_Previews: PreviewProvider {
    static var previews: some View {
        MapBallon()
            .frame(width: 300, height: 240)
            .foregroundColor(.brandPrimary)
            .border(Color.black)
    }
}
