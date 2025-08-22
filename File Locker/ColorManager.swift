//
//  ColorManager.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/6.
//

import Foundation
import UIKit
extension UIColor {
    static func fromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
//    convenience init(rgb: UInt) {
//        self.init(
//            red: CGFloat((rgb & 0xFFFF0000) >> 16) / 255.0,
//            green: CGFloat((rgb & 0x00FF0000) >> 8) / 255.0,
//            blue: CGFloat(rgb & 0x0000FF00) / 255.0,
//            alpha: 1.0
//        )
//    }
//    static func color(withHex hex: UInt32) -> UIColor {
//        let blue = Int((hex & 0xFF0000) >> 16)
//        let green = Int((hex & 0x00FF00) >> 8)
//        let red = Int(hex & 0x0000FF)
//        
//        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
//    }
}
class ColorManager : NSObject {
    
}
