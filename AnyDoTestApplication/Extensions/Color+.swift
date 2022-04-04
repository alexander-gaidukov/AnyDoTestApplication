//
//  Color+.swift
//  AnyDoTestApplication
//
//  Created by Alexandr Gaidukov on 04.04.2022.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        var hexValue = hex
        if hexValue.hasPrefix("#") { _ = hexValue.removeFirst() }
        
        let scanner = Scanner(string: hexValue)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff
        )
    }
}

extension Color {
    static let lightGray: Color = Color(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0)
}
