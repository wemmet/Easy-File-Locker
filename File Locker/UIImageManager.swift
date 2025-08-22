//
//  UIImageManager.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/6.
//

import Foundation
import UIKit
class UIImageManager: NSObject {
   static func fixImageOrientation(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        if image.imageOrientation == .up {
            return image
        }
        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case.down,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case.left,.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case.right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        case.up,.upMirrored:
            break
        @unknown default:
            break
        }
        switch image.imageOrientation {
        case.upMirrored,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case.leftMirrored,.rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case.up,.down,.left,.right:
            break
        @unknown default:
            break
        }
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        switch image.imageOrientation {
        case.left,.leftMirrored,.right,.rightMirrored:
            ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        if let newCGImage = ctx?.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        return nil
    }
    
    static func rotateImageDegrees(_ image: UIImage?, degrees: CGFloat) -> UIImage {
        // 将度数转换为弧度
        let radians = degrees * CGFloat.pi / 180.0
        
        // 计算旋转后的图像尺寸
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: image!.size))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // 创建一个基于位图的图形上下文
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, image!.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image!
        }
        
        // 将上下文的原点移动到图像中心
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        // 应用旋转
        context.rotate(by: radians)
        // 将原点移回到原来的位置并绘制图像
        context.translateBy(x: -image!.size.width / 2, y: -image!.size.height / 2)
        image!.draw(at: .zero)
        
        // 从上下文中获取新的图像
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image!
    }
}
