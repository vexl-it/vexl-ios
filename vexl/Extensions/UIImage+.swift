//
//  UIImage+.swift
//  vexl
//
//  Created by Adam Salih on 27.10.2022.
//

import UIKit
import CoreGraphics
import Accelerate

extension UIImage {

    func resizeWithScaleAspectFitMode(to dimension: CGFloat) -> UIImage? {
        if max(size.width, size.height) <= dimension { return self }
        var newSize: CGSize!
        let aspectRatio = size.width/size.height

        if aspectRatio > 1 {
            newSize = CGSize(width: dimension, height: dimension / aspectRatio)
        } else {
            newSize = CGSize(width: dimension * aspectRatio, height: dimension)
        }

        return resize(to: newSize)
    }

    public func resize(to newSize: CGSize) -> UIImage? {
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace else { return nil }

        let width = Int(newSize.width)
        let height = Int(newSize.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(cgImage, in: rect)

        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }
}
