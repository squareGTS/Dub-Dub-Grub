//
//  CKAsset+Ext.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 23.12.2022.
//

import UIKit
import CloudKit

extension CKAsset {
    func converToUIImage(in dimention: ImageDimention) -> UIImage {
        let placeholder = dimention.placeHolder
        
        guard let fileUrl = self.fileURL else { return placeholder }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            return UIImage(data: data) ?? placeholder
        } catch {
            return placeholder
        }
    }
}
