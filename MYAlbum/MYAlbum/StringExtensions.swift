//
//  UIColorExtensions.swift
//  Homehapp
//
//  Created by DEVELOPER on 06/01/16.
//  Copyright © 2016 Homehapp. All rights reserved.
//


import Foundation

/// Extensions to the String class.
extension String {
    /**
    Adds a read-only length property to String.
    
    - returns: String length in number of characters.
    */
    public var length: Int {
        return self.characters.count
    }

    /** 
     Trims all the whitespace-y / newline characters off the begin/end of the string.
     
     - returns: a new string with all the newline/whitespace characters removed from the ends of the original string
     */
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /**
    Returns an URL encoded string of this string.
    
    - returns: String that is an URL-encoded representation of this string.
    */
    public var urlEncoded: String? {
        get {
            return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
    }

    /**
    Convenience method for a more familiar name for string splitting.
    
    - parameter separator: string to split the original string by
    - returns: the original string split into parts
    */
    public func split(_ separator: String) -> [String] {
        return components(separatedBy: separator)
    }
    
    /**
    Checks whether the string contains a given substring.
    
    - parameter s: substring to check for
    - returns: true if this string contained the given substring, false otherwise.
    */
    public func contains(_ s: String) -> Bool {
        return (self.range(of: s) != nil)
    }
    
    /**
    Returns a substring of this string from a given index up the given length.
    
    - parameter startIndex: index of the first character to include in the substring
    - parameter length: number of characters to include in the substring
    - returns: the substring
    */
    public func substring(_ startIndex: Int, length: Int) -> String {
        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
        let end = self.characters.index(self.startIndex, offsetBy: startIndex + length)
        
        return self[start..<end]
    }
    
    /**
    Returns a substring of this string from a given index to the end of the string.
    
    - parameter startIndex: index of the first character to include in the substring
    - returns: the substring from startIndex to the end of this string
    */
    public func substring(_ startIndex: Int) -> String {
        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
        return self[start..<self.endIndex]
    }
    
    /**
    Splits the string into substring of equal 'lengths'; any remainder string
    will be shorter than 'length' in case the original string length was not multiple of 'length'.
    
    - parameter length: (max) length of each substring
    - returns: the substrings array
    */
    public func splitEqually(_ length: Int) -> [String] {
        var index = 0
        let len = self.length
        var strings: [String] = []
        
        while index < len {
            let numChars = min(length, (len - index))
            strings.append(self.substring(index, length: numChars))
            
            index += numChars
        }
        
        return strings
    }
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
