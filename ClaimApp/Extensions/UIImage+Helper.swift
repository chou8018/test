//
//  UIImage+Helper.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/9/7.
//

import UIKit

extension UIImage {
    
    /// - Returns: data
    func compressOriginalImage(_ toKb: Int = 10485760) -> Data?{
        var compression: CGFloat = 1
        let minCompression: CGFloat = 0.1
        var imageData = self.jpegData(compressionQuality: compression)
        if imageData!.count < toKb {
            return imageData
        }
        while imageData!.count > toKb, compression > minCompression {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        return imageData
    }
}
