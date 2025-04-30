//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    static let hashtagPattern = "(?:|$)#[\\p{L}0-9_]+"
    static let mentionPattern = "\\B\\@([a-zA-Z0-9_.-]{1,})(@[\\w.-]+)?"
    static let urlPattern = "(https?://)?(www\\.)?(?!\\d+\\.\\d+$)([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,}(/[a-zA-Z0-9\\-_'#:,\\.@%&;=+~?/]*)?"
    static let emailPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    static let hashtagRegex = try! NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive])
    static let mentionRegex = try! NSRegularExpression(pattern: mentionPattern, options: [.caseInsensitive])
    static let urlRegex = try! NSRegularExpression(pattern: urlPattern, options: [.caseInsensitive])
    static let emailRegex = try! NSRegularExpression(pattern: emailPattern, options: [.caseInsensitive])

    private static var cachedRegularExpressions: [String: NSRegularExpression] = [
        hashtagPattern: hashtagRegex,
        mentionPattern: mentionRegex,
        urlPattern: urlRegex,
        emailPattern: emailRegex
    ]
    private static let cacheLock = NSLock()
    
    static func getElements(from text: String, with pattern: String, range: NSRange? = nil) -> [NSTextCheckingResult] {
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        let searchRange = range ?? NSRange(location: 0, length: text.utf16.count)
        return elementRegex.matches(in: text, options: [], range: searchRange)
    }
    
    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let cachedRegex = cachedRegularExpressions[pattern] {
            return cachedRegex
        }
        guard let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        cachedRegularExpressions[pattern] = createdRegex
        return createdRegex
    }
}
