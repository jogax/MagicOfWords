//
//  Extensions.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 31/01/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import GameplayKit

//let iPhone_X = "iPhone X"


public extension UIDevice {
    enum UIDeviceTypes: Int {
        case noDevice = 0, iPodTouch5, iPodTouch6, iPhone4, iPhone4s, iPhone5, iPhone5c, iPhone5s, iPhone6, iPhone6Plus, iPhone6s, iPhone6sPlus, iPad2,
        iPad3, iPad4, iPadAir, iPadAir2, iPadMini, iPadMini2, iPadMini3, iPadMini4, iPadPro, appleTV, simulator}
    
    var deviceID: String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }

    func getModelCode(ident: String = "")->Int {
//        let bounds = UIScreen.main.bounds
//        let width = bounds.width
//        let height = bounds.height
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = ident != "" ? ident : machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let iPodName = "iPod"
        let iPhoneName = "iPhone"
        let iPadName = "iPad"
        let AppleTVName = "AppleTV"
        let other1Name = "i386"
        let other2Name = "x86_64"
        var returnCode = 0
        var index = 0

        let indexOfComma = identifier.index(from: 0, of: ",")
        if identifier.beginsWith(iPodName) {
            returnCode = 10000
            index = iPodName.length
        } else if identifier.beginsWith(iPhoneName) {
            returnCode = 20000
            index = iPhoneName.length
        } else if identifier.beginsWith(iPadName) {
            returnCode = 30000
            index = iPadName.length
        } else if identifier.beginsWith(AppleTVName) {
            returnCode = 40000
            index = AppleTVName.length
        } else if identifier.beginsWith(other1Name) {
            returnCode = 50000
            return returnCode
        } else if identifier.beginsWith(other2Name) {
            returnCode = 60000
            return returnCode
        } else {
            index = 0
            returnCode = 1
        }
        if let firstNumber = Int(identifier.subString(at: index, length: indexOfComma! - index)) {
            if let secondNumber = Int(identifier.subString(at: indexOfComma! + 1, length: identifier.length + 1)) {
                return returnCode + firstNumber * 100 + secondNumber
            }
        }
        return 0
    }
    
    func convertIntToModelName(value: Int)-> String {
        let iPodName = "iPod"
        let iPhoneName = "iPhone"
        let iPadName = "iPad"
        let AppleTVName = "AppleTV"
        let other1Name = "i386"
        let other2Name = "x86_64"
        var returnValue = ""
        let deviceType = value / 10000
        let firstNumber = String((value % 10000) / 100)
        let secondNumber = String((value % 10000) % 100)
        switch deviceType {
        case 1:
            returnValue = iPodName
        case 2:
            returnValue = iPhoneName
        case 3:
            returnValue = iPadName
        case 4:
            returnValue = AppleTVName
        case 5:
            returnValue = other1Name
        case 6:
            returnValue = other2Name
        default:
            break
        }
        return convertIDToModelName(identifier: returnValue + firstNumber + "," + secondNumber)
    }
    
    private func convertIDToModelName(identifier: String, width: CGFloat = 0, height: CGFloat = 0)->String {
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2nd"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2nd"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3rd"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4th"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7"
        case "iPad6,11", "iPad6,12":                    return "iPad 9.7 5th"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5"
        case "iPad7,5", "iPad7,6":                      return "iPad 9.7 6th"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro 11"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 2th"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro 12.9 3th"
        case "iPad11,1", "iPad11,2":                    return "iPad mini 5th"
        case "iPad11,3", "iPad11,4":                    return "iPad Air 3rd"

        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":
            switch (width, height) {
            case (320, 480):                            return "iPhone 4s Sim"
            case (320, 568):                            return "iPhone 5s Sim"
            case (375, 667):                            return "iPhone 6  Sim"
            case (414, 736):                            return "iPhone 6 Plus Sim"
            case (768, 1024):                           return "iPad Air Sim"
            case (1024, 1366):                          return "iPad Pro Sim"
            case (375, 812):                            return "iPhone_X Sim"
            default:                                    return identifier
            }
        default:                                        return identifier
        }
    }
    
    var modelName: String {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return convertIDToModelName(identifier: identifier, width: width, height: height)
    }
}

extension Double {
    var twoDecimals: Double {
        return nDecimals(2)
    }
    var threeDecimals: Double {
        return nDecimals(3)
    }
    func nDecimals(_ n: Int)->Double {
        let multiplier: Double = pow(10.0,Double(n))
        let divisior: Double = 1.0 / multiplier
        var v: Double = self
        v = v * multiplier
        
        return v.rounded() * divisior
    }
    
}

extension Int {
    var HourMinSec: String {
        //        var days: Int = 0
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = self
        if self > 59 {
            seconds = self % 60
            minutes = self / 60
        }
        if minutes > 59 {
            hours = minutes / 60
            minutes = minutes % 60
        }
        //        if hours > 23 {
        //            days = hours / 24
        //            hours = hours % 24
        //        }
        //        let daysString = days > 0 ? ((days < 10 ? "0":"") + String(days) + ":") : ""
        let hoursString = hours > 0 ? String(hours) + "h " : "0h "
        let minutesString = (minutes < 10 ? "0" : "") + String(minutes) + "m "
        let secondsString = (seconds < 10 ? "0" : "") + String(seconds) + "s"
        return hoursString + minutesString + secondsString
    }
    var HourMin: String {
        //        var days: Int = 0
        var hours: Int = 0
        var minutes: Int = 0
 
        minutes = self % 60
        hours = self / 60
        let hoursString = String(hours) + "h "
        let minutesString = (minutes < 10 ? "0" : "") + String(minutes) + "m "
//        let secondsString = hours > 0 ? (seconds < 10 ? "0" : "") : String(seconds) + "s"
        return hoursString + minutesString// + secondsString
    }
    func isMemberOf(_ values: Int...)->Bool {
        for index in 0..<values.count {
            if self == values[index] {
                return true
            }
        }
        return false
    }
    
    func between(min: Int, max: Int)->Bool {
        return self >= min && self <= max
    }
    
    func rightJustified(_ length: Int)->String {
        var numberString = String(self)
        var countLeadingBlanks = length - numberString.length
        while countLeadingBlanks > 0 {
            numberString = " " + numberString
            countLeadingBlanks -= 1
        }
        return numberString
    }
    
    func toCGFloat()->CGFloat {
        return CGFloat(self)
    }
    
    func isOdd() -> Bool {
        if (self % 2 == 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func toBinary(len: Int = 0)->String {
        let spacing = 4
        var string = ""
        var shifted = self
        for index in 0...63 {
            let digit = shifted & 1 == 0 ? "0" : "1"
            string = digit + string
            if index % spacing == 3 {
                string = " " + string
            }
            shifted = shifted >> 1
        }
        let offset = len == 0 ? 0 : string.count - len - len / spacing
        let at = string.index(string.startIndex, offsetBy: offset)
        let returnString = String(string[at...])
        return returnString
    }
    
    /// Returns a random Int point number between 0 and Int.max.
    public static var random: Int {
        return Int.random(n: Int.max)
    }
    
    /// Random integer between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random Int point number between 0 and n max
    public static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    ///  Random integer between min and max
    ///
    /// - Parameters:
    ///   - min:    Interval minimun
    ///   - max:    Interval max
    /// - Returns:  Returns a random Int point number between 0 and n max
    public static func random(min: Int, max: Int) -> Int {
        return Int.random(n: max - min + 1) + min
        
    }
    
    public func yearMonthDay()-> String {
        var returnValue = ""
        if self > 0 {
            let year = String(self / 10000)
            var month = String((self % 10000) / 100)
            month = month.length == 1 ? "0" + month : month
            var day = String((self % 10000) % 100)
            day = day.length == 1 ? "0" + day : day
            returnValue = year + "-" + month + "-" + day
        }
        return returnValue
    }


}

extension UInt8 {
    func toBinary(len: Int = 0)->String {
        return Int(self).toBinary(len: len)
    }
    
    func countOnes()->Int {
        var counter = 0
        var myValue = self
        while myValue > 0 {
            counter += Int(myValue & 1)
            myValue >>= 1
        }
        return counter
    }
}

extension UInt16 {
    func toBinary(len: Int = 0)->String {
        return Int(self).toBinary(len: len)
    }
}

extension CGFloat {
    func between(_ min: CGFloat, max: CGFloat)->Bool {
        return self >= min && self <= max
    }
    
    func isPositiv()->Bool {
        return (self >= 0)
    }
    
    func isNegativ()->Bool {
        return (self < 0)
    }
    
    func nDecimals(n: Int)->CGFloat {
        let multiplier: CGFloat = pow(10.0,CGFloat(n))
        let divisior: CGFloat = 1.0 / multiplier
        var v: CGFloat = self
        v = v * multiplier
        
        return v.rounded() * divisior
    }
    
    func nDecimals(n: Int)->String {
        let format = "%.\(n)f"
        return String(format: format, self)
    }
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
    
    public func toRadian(_ degree: CGFloat)->CGFloat {
        return degree * CGFloat(CGFloat.pi / 180)
    }
    


    
}

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        return Float(arc4random()) / Float(0xFFFFFFFF)
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}



extension String {
        
    func contains(strings: [String])->Bool {
        for string in strings {
            if self.range(of:string) != nil {
                return true
            }
        }
        return false
    }
    
    func index(from: Int, of: String)->Int? {
        let length = of.length
        for ind in from..<self.length - length + 1 {
            if self.subString(at: ind, length: length) == of {
                return ind
            }
        }
        return nil
    }
    
    func myUpperCased()->String {
        let scharfesS = "ß"
        if self.contains(scharfesS) {
            var returnValue = ""
            for char in self {
                if String(char) == scharfesS  {
                    returnValue.append(scharfesS)
                } else {
                    returnValue.append(char.uppercased())
                }
            }
            return returnValue
        }
        return self.uppercased()
    }
    
    func replace(_ what: String, values: [String])->String {
        let toArray = self.components(separatedBy: what)
        var endString = ""
        var vIndex = 0
        for index in 0..<toArray.count {
            endString += toArray[index] + (vIndex < values.count ? values[vIndex] : "")
            vIndex += 1
        }
        return endString
    }
    
    func isMemberOf(_ values: String...)->Bool {
        for index in 0..<values.count {
            if self == values[index] {
                return true
            }
        }
        return false
    }
    
    var length: Int {
        return self.count
    }
    
    func dataFromHexadecimalString() -> Data? {
        let data = NSMutableData(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.append([num], length: 1)
        }
        
        return data as Data?
    }
    
    func isNumeric()->Bool {
        var OK = false
        if Int(self) != nil
        {
            OK = true
        }
        return OK
    }
    
    func fill(with character: String = "0", toLength length: Int = 8) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }
        
        return String(repeating: character, count: padCount) + self
    }
    
    func endingSubString(at: Int) -> String {
        let indexStartOfText = self.index(self.startIndex, offsetBy: at)
        let returnValue = String(self[indexStartOfText...])
        return returnValue
    }

    func startingSubString(length: Int) -> String {
        return subString(at: 0, length: length)
    }
    
    func beginsWith(_ with: String)->Bool {
        return subString(at: 0, length: with.length) == with
    }
    
    func endsWith(_ with: String)->Bool {
        if length < with.length {
            return false
        }
        return subString(at: length - with.length, length: with.length) == with
    }
    
    mutating func subString(at: Int, length: Int, remove: Bool) -> String.SubSequence {
        let indexStartOfText = self.index(self.startIndex, offsetBy: at)
        let indexEndOfText = self.index(self.startIndex, offsetBy: at + length)
        let returnString = self[indexStartOfText..<indexEndOfText]
        if remove {
            self.removeSubrange(indexStartOfText..<indexEndOfText)
        }
        return returnString
    }
    
    func char(at: Int)->String {
        return subString(at:at, length: 1)
    }
    
    func firstChar()->String {
        return subString(at:0, length: 1)
    }
    
    func lastChar()->String {
        return subString(at: length - 1, length: 1)
    }
    func subString(at: Int, length: Int) -> String {
        let newLength = length > self.length ? self.length : length
        if self.length > 0 && newLength > 0 {
            let indexStartOfText = self.index(self.startIndex, offsetBy: at)
            var lastPosition = at + newLength
            if lastPosition >= self.length {
                lastPosition = self.length
            }
            let indexEndOfText = self.index(self.startIndex, offsetBy: lastPosition)
            let returnString = self[indexStartOfText..<indexEndOfText]
            return String(returnString)
        } else {
            return ""
        }
    }
    
    func begins(with: String)->Bool {
        return self.subString(at: 0, length: with.count) == with
    }
    func ends(with: String)->Bool {
        let indexStartOfText = self.index(self.endIndex, offsetBy: -with.count)
        if self[indexStartOfText..<endIndex] == with {
            return true
        } else {
            return false
        }
    }

    func fixLength(length: Int, center: Bool = false, leadingBlanks: Bool = true)->String {
        var returnValue: String = self
        if returnValue.count < length {
            if center {
                repeat {
                    returnValue = " " + returnValue
                    if returnValue.count < length {
                        returnValue += " "
                    }
                } while returnValue.count < length

            } else {
                repeat {
                    returnValue = leadingBlanks ? " " + returnValue : returnValue + " "
                } while returnValue.count < length
            }
        }
        return returnValue
    }
    func height(withConstrainedWidth width: CGFloat = 0, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat = 0, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    public func changeChars(at: Int, to: String)->String {
        var result = ""
        if at > 0 {
            result += self.subString(at: 0, length: at)
        }
        result += to
        if result.length < self.length {
            result += self.subString(at: result.length, length: self.length - result.length)
        }
        return result
    }

}
extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}


extension UIColor {
    static public func greenAppleColor()->UIColor {
        return UIColor(red: 0x52/0xff, green: 0xD0/0xff, blue: 0x17/0xff, alpha: 1.0)
    }
//    var rgba:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        return (red, green, blue, alpha)
//    }
//
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: alpha
        )
    }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

extension Data {
    
    //    var hexString: String? {
    //        let buf = UnsafePointer<UInt8>(bytes)
    //        let charA = UInt8(UnicodeScalar("a").value)
    //        let char0 = UInt8(UnicodeScalar("0").value)
    //
    //        func itoh(_ value: UInt8) -> UInt8 {
    //            return (value > 9) ? (charA + value - 10) : (char0 + value)
    //        }
    //
    //        let ptr = UnsafeMutablePointer<UInt8>(allocatingCapacity: count * 2)
    //
    //        for i in 0 ..< count {
    //            ptr[i*2] = itoh((buf[i] >> 4) & 0xF)
    //            ptr[i*2+1] = itoh(buf[i] & 0xF)
    //        }
    //
    //        return String(bytesNoCopy: ptr, length: count*2, encoding: String.Encoding.utf8, freeWhenDone: true)
    //    }
    
    var hexString: String? {
        
        let buf = self
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(_ value: UInt8) -> UInt8 {
            return (value > 9) ? (charA + value - 10) : (char0 + value)
        }
        
        var str = [UInt8]()
        
        for i in 0 ..< count {
            str.append(itoh((buf[i] >> 4) & 0xF))
            str.append(itoh(buf[i] & 0xF))
        }
        
        return NSString(bytes: str, length: str.count, encoding: String.Encoding.utf8.rawValue) as String?
        
    }
    
    
}

extension Date {
    func toString()->String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "UTC")
        let returnValue = df.string(from: self)

        return returnValue
    }
    
    var yearMonthDay: Int {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: self) * 10000
            let month = calendar.component(.month, from: self) * 100
            let day = calendar.component(.day, from: self)
            return year + month + day
        }
    }

    init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        //        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        let userCalendar = Calendar.current // user calendar
        self = userCalendar.date(from: dateComponents)!
    }
    
    func getDateDiff(start: Date) -> String  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.hour,
                                                      Calendar.Component.minute,
                                                      Calendar.Component.nanosecond], from: start, to: self)
        let milliseconds = String(dateComponents.nanosecond! / 1000000)
        let hours = String(dateComponents.hour!)
        let minutes = String(dateComponents.minute!)
        return "\(hours):\(minutes):\(milliseconds)"
    }
    
}

extension UIViewController {
    func showAlert(_ alert:UIAlertController, delay: Double = 0) {
        if (presentedViewController != nil) {
            dismiss(animated: true, completion: {
                self.present(alert, animated: true, completion: {
                })
                
            })
        } else {
            self.present(alert, animated: true, completion: {
            })
            
        }
        if delay > 0 {
            let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) { () -> Void in
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func stopAlert() {
        if (presentedViewController != nil) {
            dismiss(animated: true, completion: {} )
            
        }
    }
    
    
}

extension TimeInterval {
    func stringFromTimeInterval() -> NSString {
        
        let ti = Int(self)
        
        let ms = Int((self) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms) as NSString
    }
}

extension UIBezierPath {
    
    class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> Self {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(0, tailWidth / 0.9),
            p(tailLength, tailWidth / 2.9),
            p(tailLength, headWidth / 2),
            p(length, 0),
            p(tailLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2.9),
            p(0, -tailWidth / 0.9)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform )
        
        path.closeSubpath()
        
        return self.init(cgPath: path)
    }
    
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

extension UIView {
    
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
    
    enum ViewSide {
        case Left, Right, Top, Bottom, All
    }
    
    func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        func addOneSideBorder(side: ViewSide) {
            switch side {
            case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
            case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
            case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
            case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
            case .All: break
            }
        }
        
        if side == .All {
            addOneSideBorder(side: .Left)
            addOneSideBorder(side: .Right)
            addOneSideBorder(side: .Top)
            addOneSideBorder(side: .Bottom)
        } else {
            addOneSideBorder(side: side)
        }
        
        layer.addSublayer(border)
    }
    func setRadiusWithShadow(_ radius: CGFloat? = nil) { // this method adds shadow to right and bottom side of button
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
    func setAllSideShadow(shadowShowSize: CGFloat = 1.0) { // this method adds shadow to allsides
        let shadowSize : CGFloat = shadowShowSize
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.frame.size.width + shadowSize,
                                                   height: self.frame.size.height + shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func createRoundedRectPath(for rect: CGRect, radius: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        
        // 1
        let midTopPoint = CGPoint(x: rect.midX, y: rect.minY)
        path.move(to: midTopPoint)
        
        // 2
        let topRightPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRightPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeftPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let topLeftPoint = CGPoint(x: rect.minX, y: rect.minY)
        
        // 3
        path.addArc(tangent1End: topRightPoint,
                    tangent2End: bottomRightPoint,
                    radius: radius)
        
        path.addArc(tangent1End: bottomRightPoint,
                    tangent2End: bottomLeftPoint,
                    radius: radius)
        
        path.addArc(tangent1End: bottomLeftPoint,
                    tangent2End: topLeftPoint,
                    radius: radius)
        
        path.addArc(tangent1End: topLeftPoint,
                    tangent2End: topRightPoint,
                    radius: radius)
        
        // 4
        path.closeSubpath()
        
        return path
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
var vSpinner : UIView?

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}


extension SKLabelNode {
    public func copyMe()->SKLabelNode {
        let returnNode = SKLabelNode()
        returnNode.fontName = self.fontName //"KohinoorBangla-Regular"
        returnNode.fontColor = self.fontColor
        returnNode.fontSize = self.fontSize
        returnNode.text = self.text
        returnNode.verticalAlignmentMode = self.verticalAlignmentMode
        returnNode.position = self.position
        returnNode.zPosition = self.zPosition
        return returnNode
    }
    public func removeShadow() {
        repeat {
            if children.count > 0 {
                self.children[0].removeFromParent()
            }
        } while self.children.count > 0    
    }
    
    public func setText(text:String) {
        self.text = text
        let shadowNode = SKLabelNode(fontNamed: self.fontName)
        shadowNode.text = self.text
        shadowNode.zPosition = self.zPosition - 1
        shadowNode.fontColor = .black
        // Just create a little offset from the main text label
        let xValue = GV.onIpad ? 3 : 1
        let yValue = GV.onIpad ? 3 : 1
        shadowNode.position = CGPoint(x: xValue, y: -yValue)
        shadowNode.verticalAlignmentMode = .center
        shadowNode.fontSize = self.fontSize
        shadowNode.alpha = 0.5
        self.removeShadow()
        self.addChild(shadowNode)
    }
}

struct PLPosSize {
    var PPos = CGPoint()
    var LPos = CGPoint()
    var PSize: CGSize? = nil
    var LSize: CGSize? = nil
}
enum SKNodeSubclassType: Int {
    case MyLabel = 0, MyButton, Grid, SKSpriteNode, Background
}

fileprivate var storedProperty_PLPosition: [ObjectIdentifier:PLPosSize?] = [:]
fileprivate var storedProperty_SubClassType: [ObjectIdentifier:SKNodeSubclassType?] = [:]



extension SKNode {
    var plPosSize: PLPosSize? {
        get {return storedProperty_PLPosition[ObjectIdentifier(self)] ?? nil}
        set {storedProperty_PLPosition[ObjectIdentifier(self)] = newValue}
    }
    var nodeType: SKNodeSubclassType? {
        get {return storedProperty_SubClassType[ObjectIdentifier(self)] ?? nil}
        set {storedProperty_SubClassType[ObjectIdentifier(self)] = newValue}
    }
    
    public func removeAllStoredPropertys() {
        let indexForType = storedProperty_SubClassType.index(forKey: ObjectIdentifier(self))
        if indexForType != nil {
            storedProperty_SubClassType.remove(at: indexForType!)
        }
        let indexForPos = storedProperty_PLPosition.index(forKey: ObjectIdentifier(self))
        if indexForPos != nil {
            storedProperty_PLPosition.remove(at: indexForPos!)
        }
    }
    public func setActPosSize() {
        let isPortrait = GV.deviceOrientation == .Portrait
        if plPosSize != nil {
            position = isPortrait ? plPosSize!.PPos : plPosSize!.LPos
            let mySize = isPortrait ? plPosSize!.PSize : plPosSize!.LSize
            switch nodeType {
            case .Grid: (self as! Grid).size = mySize!
            case .MyButton: (self as! MyButton).size = mySize!
            case .SKSpriteNode: (self as! SKSpriteNode).size = mySize!
            default: break
            }
        }
    }
    public func setPosAndSizeForAllChildren() {
        for child in children {
            if child.nodeType != .Background {
                child.setActPosSize()
            }
        }
    }
}





//extension GCHelper {
//    
//    /// CommandFormat:
//    ///    xxx°yyy°zzz°www... -> xxx = CommandType
//    //    public enum CommandType: Int {
//    //        case none = 0, GameParams, Last
//    //    }
//    //
//    //    public func codeData(type: CommunicationCommands, packageNr: Int, level: Int, gameNr: Int)->Data {
//    //        var command = String(type.rawValue)
//    //        command += GV.separator
//    //        command += String(packageNr)
//    //        command += GV.separator
//    //        command += String(level)
//    //        command += GV.separator
//    //        command += String(gameNr)
//    //        let data = command.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
//    //        return data
//    //    }
//    
//    public func sendInfo(command: CommunicationCommands, message: [String]) {
//        var command = String(command.rawValue)
//        for param in message {
//            command += GV.separator
//            command += param
//        }
//        let data = command.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
//        if match != nil {
//            try! match.sendData(toAllPlayers: data , with: .reliable)
//        }
//    }
//    
//    public func disconnectFromMatch() {
//        if match != nil {
//            match.disconnect()
//        }
//    }
//    
//    public func decodeData(data: Data)->(command: CommunicationCommands, parameters: [String]) {
//        let commandString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
//        let stringTable = commandString.components(separatedBy: GV.separator)
//        let command = CommunicationCommands(rawValue: Int(stringTable[0])!)
//        return (command: command!, parameters: Array(stringTable[1..<stringTable.count]))
//    }
//    
//}










