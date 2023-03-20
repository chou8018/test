//
//  Dictionary+Helper.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 10/1/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import Foundation

struct CustomKeyPath {
    var segments: [String]

    var isEmpty: Bool { return segments.isEmpty }
    var path: String {
        return segments.joined(separator: ".")
    }

    /// Strips off the first segment and returns a pair
    /// consisting of the first segment and the remaining key path.
    /// Returns nil if the key path has no segments.
    func headAndTail() -> (head: String, tail: CustomKeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        if tail.count > 0 {
            let head = tail.removeFirst()
            return (head, CustomKeyPath(segments: tail))
        }
        return nil
    }
}

/// Initializes a KeyPath with a string of the form "this.is.a.keypath"
extension CustomKeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension CustomKeyPath: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

extension Dictionary where Key == String, Value: Any {
    
    subscript(keyPath keyPath: CustomKeyPath) -> Any? {
        
        get {
            
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return nil
            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
                // Reached the end of the key path.
                return self[head]
            case let (head, remainingKeyPath)?:
                // Key path has a tail we need to traverse.
                switch self[head] {
                case let nestedDict as [Key: Any]:
                    // Next nest level is a dictionary.
                    // Start over with remaining key path.
                    return nestedDict[keyPath: remainingKeyPath]
                default:
                    // Next nest level isn't a dictionary.
                    // Invalid key path, abort.
                    return nil
                }
            }
        }
    
    }
    
    func lenientNumber(_ keyPath: CustomKeyPath) -> NSNumber? {
        if let n = self.number(keyPath) {
            return n
        }
        return numberFromString(keyPath)
    }
    
    func number(_ keyPath: CustomKeyPath) -> NSNumber? {
        return self[keyPath: keyPath] as? NSNumber
    }
    
    func numberFromString(_ keyPath: CustomKeyPath) -> NSNumber? {
        if let nAsString = self[keyPath: keyPath] as? String,
            let nAsDouble = Double(nAsString) {
            return NSNumber(value: nAsDouble)
            
        } else {
            return nil
        }
    }
    
    func string(_ keyPath: CustomKeyPath) -> String? {
        return self[keyPath: keyPath] as? String
    }
    
    func jsonObject(_ keyPath: CustomKeyPath) -> [String: Any]? {
        return self[keyPath: keyPath] as? [String: Any]
    }
    
    func jsonArray(_ keyPath: CustomKeyPath) -> [Any]? {
        return self[keyPath: keyPath] as? [Any]
    }
   
    func value<T>(_ keyPath: CustomKeyPath) -> T? {
        return self[keyPath: keyPath] as? T
    }
    
    func recursivelySearchForValue(key: String) -> Any? {
        
        for (k, v) in self {
            if k == key {
                return v
                
            } else if let `v` = v as? [String: Any] {
                return v.recursivelySearchForValue(key: key)
            }
        }
        return nil
        
    }
    
}

extension Dictionary {
    mutating func merge<S>(_ other: S)
        where S: Sequence, S.Iterator.Element == (key: Key, value: Value){
            for (k ,v) in other {
                self[k] = v
        }
    }
}
