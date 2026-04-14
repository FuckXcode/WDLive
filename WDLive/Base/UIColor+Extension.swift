//
//  UIColor+Extension.swift
//  WDLive
//
//  Created by scott on 2024/12/6.
//
import UIKit
/*
 扩展UIColor

 思想：
 带参数，使用初始化器
 不带参数，使用计算属性
 */

extension UIColor {

    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }

    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF)
        let g = CGFloat((hex >> 8) & 0xFF)
        let b = CGFloat(hex & 0xFF)
        self.init(r, g, b, alpha: alpha)
    }

    convenience init?(_ hex: String) {

        // 1.判断字符串长度
        guard hex.count >= 6 else {
            return nil
        }

        // 2.转为大写字母
        var rawHex = hex.uppercased()

        // 3.判断前缀，截取
        if rawHex.hasPrefix("##") || rawHex.hasPrefix("0X") {
            let startIndex = rawHex.index(rawHex.startIndex, offsetBy: 2)
            rawHex = String(rawHex[startIndex...])
        }

        if rawHex.hasPrefix("#") {
            let startIndex = rawHex.index(rawHex.startIndex, offsetBy: 1)
            rawHex = String(rawHex[startIndex...])
        }

        let scanner = Scanner(string: rawHex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(CGFloat(r), CGFloat(g), CGFloat(b))
    }

    /// 获取随机颜色
    class var randomColor: UIColor {
            let r = arc4random_uniform(256)
            let g = arc4random_uniform(256)
            let b = arc4random_uniform(256)
            return UIColor(CGFloat(r), CGFloat(g), CGFloat(b))
    }

    /// 获取R/G/B
    // swiftlint:disable   large_tuple
    static func getRGB(from color: UIColor) -> (CGFloat, CGFloat, CGFloat)? {
        guard let rgbColor = color.cgColor.components else {
            return nil
        }
        return (rgbColor[0] * 255.0, rgbColor[1] * 255.0, rgbColor[2] * 255.0)
    }

    /// 计算两个RGB颜色的差值
    /// - Parameters:
    ///   - sourceColor: 起点
    ///   - targetColor: 目标
    /// - Returns: R/G/B 的差值
    static func getDeltaColor(_ sourceColor: UIColor, _ targetColor: UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard let sourceRGB = self.getRGB(from: sourceColor) else {
            fatalError("must be rgb color spaces")
        }
        guard let targetRGB = self.getRGB(from: targetColor) else {
            fatalError("must be rgb color spaces")
        }

        let deltaR = targetRGB.0 - sourceRGB.0
        let deltaG = targetRGB.1 - sourceRGB.1
        let deltaB = targetRGB.2 - sourceRGB.2
        return (deltaR, deltaG, deltaB)
    }
}
