//
//  extensions.swift
//  ToolsExtensions
//
//  Created by Oz Shabat on 30/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
   
    /// Will find a range of string in an attributed string
    public func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
}
extension String {

    /// Will return letters from a stirng
    public var letters: String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
    
    /// Will convert to a base64 type of string
    public func toBase64String() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Will return only digits plus decimal point
    public var digitsWithDecimal: Self { trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted) }
    
    
    /// Will capitalize the first letter of a string (not in place)
    public func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    /// will seperate characters every n times with a seperator (like 123456 to 12:34:56)
    public func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
    public func lastIndexOf(string: String) -> Int? {
        guard let index = range(of: string, options: .backwards) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
    
    public func firstIndexOf(string: String) -> Int? {
        guard let index = range(of: string) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
    
    /// Will remove a prefix of a string
    public func removePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
    
    /// Will imitate Java's substring(:)
    public func substring(_ from: Int, _ to: Int) -> String {
        
        // as Java behaviour
        if from == to {
            return ""
        }
        
        let newStr = self[from...(to - 1)]
        return newStr
    }
    
    
    /// Will capitalize the first letter of  string
    public mutating func capitalizeFirstLetterInPlace() {
        self = self.capitalizeFirstLetter()
    }
    
    /// Will replace all of the ocurrences of a string in string with a string
    public func replace(_ target: String, _ withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    public func boolValueFromString() -> Bool {
        return NSString(string: self).boolValue
    }
    
    /// Will strip all non digits from a string
    public var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    /// Will strip all non alpha characters from a string
    public var alpha: String {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
    
    /// Will replace the last occurrence of a char in a string
    public func replaceLastOccurrenceOfString(_ searchString: String,
                                       with replacementString: String,
                                       caseInsensitive: Bool = true) -> String {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
    
    /// Will turn a data object containing this 64 format string
    public func toBase64Data() -> Data? {
        return Data(base64Encoded: self)
    }
    
    
    // substring. To use:
    // let myStr = "lola"
    // let halfHint: String = myStr[0...myStr.count-2]
    /// substring functions
    public subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    public subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    public subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
}

extension RangeReplaceableCollection where Self: StringProtocol {
    
    /// Will return only digits
    var digits: Self { filter(\.isWholeNumber) }
}

extension Array where Element: Equatable {
    
    // Will remove the first collection element that is equal to the given object
    public mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

/// Will cpaitalize each word in an array of strings
extension Array where Element == String {
    public func capitalize() -> [String] {
        var newArr = [String]()
        forEach { it in
            newArr.append(it.capitalized)
        }
        return newArr
    }
}

extension Array where Element: Sequence {
    
    /// will join a bunch of arrays to one array
    public func join() -> Array<Element.Element> {
        return self.reduce([], +)
    }
}

extension Array where Element == UInt8  {
    
    /// Will return the string representation of an array
    public func toString() -> String {
        return description
    }
    
    /// Will slice an array from a starting point to an end point
    public func slice(_ from: Int, _ to: Int? = nil) -> [UInt8] {
        var start = from
        var end = count - 1
        
        if from < 0 {
            if (to == nil) {
                let toStart = count + from
                if(toStart <= 0) {
                    start = 0
                } else {
                    start = count + from
                }
                end = count - 1
            }
        } else {
            if let _to = to {
                start = from
                if _to <= 0 {
                    end = count - 1 + _to
                } else {
                    end = _to - 1
                }
            }
        }
        if start == count {
            if(end == count - 1) {
                return [UInt8]()
            }
            start = count - 1
        }
        if end < start {
            end = count - 1
        }
        return Array(self[start...end])
    }
    
    /// Will parse an array to an UTF string
    public func toUTFString() -> String? {
        if let string = String( bytes: self, encoding: .utf8) {
            return string
        } else {
            print("not a valid UTF-8 sequence")
            return ""
        }
    }
    
    /// Will parse an array to Hex string
    var toHexaString: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
    
}


extension StringProtocol {
    public var hexa: [UInt8] {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
    
    public var data: Data { .init(utf8) }
    public var bytes: [UInt8] { .init(utf8) }
}

extension UUID {
    
    /// Will return a UUID of an array
    public func asUInt8Array() -> [UInt8]{
        let (u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16) = self.uuid
        return [u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16]
    }
}


extension KeyValuePairs where Key == String {
    
    /// Will return a specfic element by key
    public func getElement(key: String) -> (String, Value)? {
        return first(where: {$0.key == key })
    }
    
    
    public subscript(key: String) -> Value? {
        get {
            return first(where: {$0.key == key })?.value
        }
    }
}

extension KeyValuePairs where Key == Int {
    
    public subscript(key: Int) -> Value? {
        get {
            return first(where: {$0.key == key })?.value
        }
    }
}

extension CountableClosedRange where Bound == Int {
    
    /// Will return a random value between a close range of numbers. To use: (0...500).randomValue
    public var randomValue: Int {
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound)))
    }
}



/// Will check if the keyboard present
extension UIApplication {

    public static func openAppSetting() {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}


extension Data {
    /// Will slice an array from a starting point to an end point
    public func slice(_ from: Int, _ to: Int? = nil) throws -> Data {
        var start = from
        var end = count - 1
        
        if from < 0 {
            if to == nil {
                let toStart = count + from
                if(toStart <= 0) {
                    start = 0
                } else {
                    start = count + from
                }
                end = count - 1
            }
        } else {
            if let _to = to {
                start = from
                if _to <= 0 {
                    end = count - 1 + _to
                } else {
                    end = _to - 1
                }
            }
        }
        if start == count {
            if end == count - 1 {
                return Data()
            }
            start = count - 1
        }
        if start > end  {
            end = count - 1
        }
        
        // last fail safe
        if start < 0 || start >= count || end < 0 || end >= count || start > end {
            throw SliceError.outOfBoundsException
        }

        
        
        return Data(Array(self[start...end]))
    }
    
    public var bytes: [UInt8] {
        return [UInt8](self)
    }
    
    
    public func printBytes() {
        print([UInt8](self))
    }
}

public enum SliceError: Error {
    case outOfBoundsException
}


extension Array where Element == UInt8 {
    public var kilobytes: Double {
        let bytes = Double(self.count)
        return bytes / 1024.0
    }
}



extension NSObject {
    
    /// Will return all of the static field in a class, which are marked with the @objc prefix
    public static func getAllStaticFields() -> [String: String] {
        
        var outputDict = [String: String]()
        var count: CUnsignedInt = 0
        let methods = class_copyPropertyList(object_getClass(self), &count)!
        for i in 0 ..< count {
            let selector = property_getName(methods.advanced(by: Int(i)).pointee)
            if let key = String(cString: selector, encoding: .utf8) {
                let res = self.value(forKey: key)
                if let value = res as? String {
                    outputDict[key] = value
                }
            }
        }
        return outputDict
    }
}
