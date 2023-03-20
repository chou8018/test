//
//  String+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 25/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

extension String {
    
    func firstCharacterUpperCased() -> String {
        guard self.count > 0 else { return self }
        let selfAsNSString = (self as NSString)
        return selfAsNSString.replacingCharacters(in: NSMakeRange(0, 1), with: selfAsNSString.substring(to: 1).uppercased())
    }
    
    var isBlank: Bool {
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
    
    func matches(_ expression: String) -> Bool {
        let p = NSPredicate(format: "SELF MATCHES %@", expression)
        return p.evaluate(with: self)
    }
    
    var isEmail: Bool {
        return self.matches("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }
    
    var isNumeric: Bool {
        return self.matches("[-+]?[0-9]*\\.?[0-9]+")
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var isNumberAndLetter: Bool {
        let reg = "^[a-zA-Z0-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if pre.evaluate(with: self) {
            return true
        }else{
            return false
        }
    }
    
    static func jsonString(from json: [String: Any]) -> String? {
        let data: Data = try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        return String(data: data, encoding: .utf8)
    }
    
    static func randomSentence(maximumWords: Int, maxWordLength: Int) -> String {
        var words = [String]()
        for _ in 0...arc4random_uniform(UInt32(maximumWords)) {
            let randomWordLength = arc4random_uniform(UInt32(maxWordLength))
            let randomWord = random(Int(randomWordLength))
            words.append(randomWord)
        }
        return words.joined(separator: " ")
    }
    
    static func random(_ length: Int) -> String {
        let cs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var characters = [Character]()
        
        for _ in 0..<length {
            let n = arc4random_uniform(UInt32(cs.count))
            let idx = cs.index(cs.startIndex, offsetBy: Int(n))
            characters.append(cs[idx])
        }
        
        return String(characters)
    }
    
    
    static func textSize(text : String , font : UIFont , maxSize : CGSize) -> CGSize{
        return text.boundingRect(with: maxSize, options: [.usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).size
    }
    
    func stringHeightWith(fontSize:CGFloat,width:CGFloat,lineSpace : CGFloat)->CGFloat{
        let font = UIFont.systemFont(ofSize: fontSize)
        
        //        let size = CGSizeMake(width,CGFloat.max)
        
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = lineSpace
        
        paragraphStyle.lineBreakMode = .byWordWrapping;
        
        let attributes = [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        
        return rect.size.height
    }    
}

protocol MTNumberProtocol {
    func conversionOfDigital(separator:String?, unit:String?) -> String
}

extension Int: MTNumberProtocol {
    func conversionOfDigital(separator:String?, unit:String?) -> String {
        "\(self)".conversionOfDigital(separator: separator, unit: unit)
    }
}

extension Double: MTNumberProtocol {
    func conversionOfDigital(separator:String?, unit:String?) -> String {
        "\(self)".conversionOfDigital(separator: separator, unit: unit)
    }
}

extension NSNumber: MTNumberProtocol {
    func conversionOfDigital(separator:String?, unit:String?) -> String {
        stringValue.conversionOfDigital(separator: separator, unit: unit)
    }
}

extension String: MTNumberProtocol {
    
    func conversionOfDigital(separator:String?, unit:String?=nil) -> String {
        
        let strings = components(separatedBy: ".")
        guard let _ = Float(self) else {
            return "0"
        }
        var value = strings.first ?? ""
        var float = ""
        if strings.count > 1 {
            float = strings.last ?? ""
        }
        
        if value.count <= 3 {
            return self
        }
        
        let count = value.count/3
        let left = value.count%3
        
        for index in 0..<count {
            if index == 0 && left != 0 {
                let index = value.index(value.startIndex, offsetBy: left)
                value.insert(contentsOf: separator ?? ",", at: index)
            }else{
                let idx = left == 0 ? (index == 0 ? 1:index+1):index
                let index = value.index(value.startIndex, offsetBy: (idx)*3+index+left)
                value.insert(contentsOf: separator ?? ",", at: index)
            }
        }
        if value.hasSuffix(separator ?? ",") {
            value.remove(at: value.index(value.endIndex, offsetBy: -1))
        }
        
        var returnValue = value
        if float.count > 0 {
            returnValue = value + "." + float
        }
        if let unit = unit, unit.count > 0 {
            return unit + " " + returnValue
        }
        return returnValue
    }
    
}

extension String {
    
    static func localized(_ key: String, comment defaultValue: String) -> String {
        
        let userController: UserController! = AppServices.shared.find(UserController.self)
        
        if let languageCode = userController.languageCode ?? Locale.current.languageCode,
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),

            let bundle = Bundle(path: path) {
            
            return NSLocalizedString(
                key,
                tableName: "Localizable",
                bundle: bundle,
                value: NSLocalizedString(key, comment: defaultValue),
                comment: ""
            )
        }
        
        return NSLocalizedString(key, comment: defaultValue)
    
    }
    
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
