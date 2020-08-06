//
//  extensions.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 30/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation
import UIKit


//hex to UIColor
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(CFloat(r) / 255), green: CGFloat(CFloat(g) / 255), blue: CGFloat(Float(b) / 255), alpha: CGFloat(Float(a) / 255))
    }
}

extension DispatchQueue {
    
    //background thread
    public static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    //main thread
    //DispatchQueue.main.async {}
    
}

extension Double {
    
    public func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }

        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1

        return decimalCount
    }
}

extension String
{
    public func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    public func replace(_ target: String, _ withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

//load nib
extension Bundle {
    
    public static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}


extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    public mutating func remove(_ object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension UIView {
    public func hide(_ hide: Bool){
        DispatchQueue.main.async {
            self.isHidden = hide
        }
    }
    
    public func blink(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, alpha: CGFloat = 0.0) {
        
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            UIView.setAnimationRepeatCount(2)
            self.alpha = alpha
        })
    }
    
    
    public func fadeIn(_ completion: @escaping () -> Void){
        self.alpha = 0.0
        self.hide(false)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: { _ in
            completion()
        })
    }
    
    public func fadeOut(_ completion: @escaping () -> Void){
        self.alpha = 1.0
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.hide(true)
            completion()
        })
    }
    
    
    public func fade(fromAlpha: CGFloat,
              toAlpha: CGFloat,
              animationOptions: UIView.AnimationOptions,
              duration: TimeInterval = 0.5,
              _ completion: @escaping () -> Void){
        self.alpha = fromAlpha
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.alpha = toAlpha
        }, completion: { _ in
            completion()
        })
    }
    
    private static let kRotationAnimationKey = "rotationanimationkey"
    public func rotate(duration: Double = 1) {
        
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }
    
    public func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
    
    
    //        UIView.transition(with: self, duration: 3, options: .transitionCrossDissolve, animations: {
    //            self.hide(out)
    //        }, completion: { _ in
    //            completion()
    //        })
    
    
    public func viewWithAccessibilityIdentifier(_ accessibilityIdentifier: String) -> UIView? {
         if(self.accessibilityIdentifier != nil &&
             self.accessibilityIdentifier == accessibilityIdentifier) {
             return self
         } else if(self.subviews.count > 0) {
             for i in 0..<self.subviews.count {
                 let found = self.subviews[i].viewWithAccessibilityIdentifier(accessibilityIdentifier)
                 if(found != nil) {
                     return found
                 }
             }
             return nil
         } else {
             return nil
         }
     }
    
    // load nib
    @discardableResult   // 1
    public func fromNib<T : UIView>() -> T? {   // 2
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        self.addSubview(contentView)     // 4
        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
        contentView.layoutAttachAll()   // 6
        return contentView   // 7
    }
    
    //    public func attachContentView(contentView: UIView) {
    //        self.addSubview(contentView)     // 4
    //        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
    //        contentView.layoutAttachAll()   // 6
    //    }
    
    public func removeViewAndConstraints() {
        if(subviews.count != 0){
            subviews.forEach{ sub in
                sub.removeViewAndConstraints()
            }
        }
        constraints.forEach{constr in constr.isActive = false}
        self.removeFromSuperview()
    }
}

// set button label for all states
extension UIButton {
    public func setAllStatesTitle(_ newTitle: String){
        self.setTitle(newTitle, for: .normal)
        self.setTitle(newTitle, for: .selected)
        self.setTitle(newTitle, for: .disabled)
    }
    
}

extension UILabel {
    public func setAttributedText(_ newText: String) {
        attributedText = NSAttributedString(string: newText, attributes: attributedText!.attributes(at: 0, effectiveRange: nil))
    }
    
    
    /// will set a regual and a bold text in the same label string
    public func setRegualAndBoldText(regualText: String,
                                     boldiText: String) {
        
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: font.pointSize)]
        let regularString = NSMutableAttributedString(string: regualText)
        let boldiString = NSMutableAttributedString(string: boldiText, attributes:attrs)
        regularString.append(boldiString)
        attributedText = regularString
    }
    
    
}

extension UIView {
    
    public func showAndClickable(show: Bool) {
        isUserInteractionEnabled = show
        hide(!show)
    }
    
    /// attaches all sides of the receiver to its parent view
    public func layoutAttachAll(margin : CGFloat = 0.0) {
        let view = superview
        layoutAttachTop(to: view, margin: margin)
        layoutAttachBottom(to: view, margin: margin)
        layoutAttachLeading(to: view, margin: margin)
        layoutAttachTrailing(to: view, margin: margin)
    }
    
    /// attaches the top of the current view to the given view's top if it's a superview of the current view, or to it's bottom if it's not (assuming this is then a sibling view).
    /// if view is not provided, the current view's super view is used
    @discardableResult
    public func layoutAttachTop(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = view == superview
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0, constant: margin)
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the bottom of the current view to the given view
    @discardableResult
    public func layoutAttachBottom(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0, constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the leading edge of the current view to the given view
    @discardableResult
    public func layoutAttachLeading(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0, constant: margin)
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the trailing edge of the current view to the given view
    @discardableResult
    public func layoutAttachTrailing(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0, constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    //    public func addConstraintsExceptBottom(_ view: UIView) {
    //        translatesAutoresizingMaskIntoConstraints = false
    //          let topConstr = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1.0, constant: 0)
    //        let trailing = NSLayoutConstraint(item: view, attribute: .trailing , relatedBy: .equal, toItem: view.superview, attribute: .trailing, multiplier: 1.0, constant: 0)
    //        let leadingConstr = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview, attribute: .leading, multiplier: 1.0, constant: 0)
    //        view.addConstraint(topConstr)
    //        view.addConstraint(trailing)
    //        view.addConstraint(leadingConstr)
    //    }
}

// regex
extension String {
    public func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public func replaceLastOccurrenceOfString(_ searchString: String,
                                       with replacementString: String,
                                       caseInsensitive: Bool = true) -> String
    {
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
}

// substring. To use:
// let myStr = "lola"
// let halfHint: String = myStr[0...myStr.count-2]
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
}


extension String {
    public func boolValueFromString() -> Bool {
        return NSString(string: self).boolValue
    }
}

public extension UIApplication {
    
    public class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UINavigationController {
    public func hasViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.first(where: {$0.isKind(of: kind)}) != nil
    }
    
    public func makeTransperent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    public func backgroundColor(uiColor: UIColor) {
        navigationBar.barTintColor = uiColor
        navigationBar.isTranslucent = false
    }
    
    
}

/// will cpaitalize each word in an array of strings
extension Array where Element == String {
    public func capitalize() -> [String] {
        var newArr = [String]()
        forEach { it in
            newArr.append(it.capitalized)
        }
        return newArr
    }
}

extension Data {
    
    public func slice(_ from: Int, _ to: Int? = nil) -> Data {
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
                return Data()
            }
            start = count - 1
        }
        if end < start {
            end = count - 1
        }
        return self[start...end]
    }
    
}

extension Array where Element == UInt8  {
    
    
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
    
    public func toUTFString() -> String? {
        if let string = String( bytes: self, encoding: .utf8) {
            return string
        } else {
            print("not a valid UTF-8 sequence")
            return ""
        }
    }
    
    var toHexaString: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
    
}


extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

extension NSData {
    
    public func readUInt8(position : Int) -> UInt8 {
        var blocks : UInt8 = 0
        self.getBytes(&blocks, length: position)
        return blocks
    }
}

extension UUID {
    public func asUInt8Array() -> [UInt8]{
        let (u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16) = self.uuid
        return [u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16]
    }
}


extension KeyValuePairs where Key == String {
    
    public func getElement(key: String) -> (String, Value)? {
        return first(where: {$0.key == key })
    }
    
    subscript(key: String) -> Value? {
        get {
            return first(where: {$0.key == key })?.value
        }
    }
    
    //    public func replaceVal(key: String, newVal: Value) {
    //        getElement(key: key).1? = newVal
    //}
}

extension KeyValuePairs where Key == Int {
    
    subscript(key: Int) -> Value? {
        get {
            return first(where: {$0.key == key })?.value
        }
    }
}

extension CountableClosedRange where Bound == Int {
    var randomValue: Int {
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound)))
    }
}

extension CountableRange where Bound == Int {
    var randomValue: Int {
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound)))
    }
}


// custom error
class AppError: LocalizedError, CustomStringConvertible {
    
    let desc: String
    
    init(str: String) {
        desc = str
    }
    
    var description: String {
        let format = NSLocalizedString("%@", comment: "Error description")
        return String.localizedStringWithFormat(format, desc)
    }
}

extension LocalizedError where Self: CustomStringConvertible {
    
    var errorDescription: String? {
        return description
    }
}

extension UITableView {
    public func setBackgroundImage(nameWithExtension: String) {
        let tempImageView = UIImageView(image: UIImage(named: nameWithExtension))
        tempImageView.frame = frame
        backgroundView = tempImageView;
    }
}
