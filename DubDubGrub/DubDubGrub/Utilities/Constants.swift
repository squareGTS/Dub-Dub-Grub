//
//  Constants.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import UIKit

enum RecordType {
    static let location = "DDGLocation"
    static let profile = "DDGProfile"
}

enum PlaceholderImage {
    static let avatar = UIImage(named: "default-avatar")!
    static let square = UIImage(named: "default-square-asset")!
    static let banner = UIImage(named: "default-banner-asset")!
}

enum ImageDimention {
    case square, banner
    
    var placeHolder: UIImage {
        switch self {
        case .square:
            return PlaceholderImage.square
        case .banner:
            return PlaceholderImage.banner
        }
    }
}

enum DeviceTypes {
    enum ScreenSize {
        static let width         = UIScreen.main.bounds.size.width
        static let height        = UIScreen.main.bounds.size.height
        static let maxLength     = max(ScreenSize.width, ScreenSize.height)
    }
    
    static let idiom             = UIDevice.current.userInterfaceIdiom
    static let nativeScale       = UIScreen.main.nativeScale
    static let scale             = UIScreen.main.scale
    
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
}
