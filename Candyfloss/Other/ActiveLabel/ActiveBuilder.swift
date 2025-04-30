//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct ActiveBuilder {

    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag, .email:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        }
    }
    
    static func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.url
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for (_, match) in matches.enumerated() where match.range.length > 0 {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            guard let maxLength = maximumLength, word.count > maxLength else {
                let range = maximumLength == nil ? match.range : (text as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }
            
            let trimmedWord = word.trim(to: maxLength)
            text = text.replacingOccurrences(of: word, with: trimmedWord)
            
            let ranges = text.ranges(of: trimmedWord)
            for (_, range) in ranges.enumerated() {
                let element = ActiveElement.url(original: word, trimmed: trimmedWord)
                if let newRange = text.nsRange(from: range) {
                    elements.append((newRange, element, type))
                }
            }
        }
        
        return (elements, text)
    }

    private static func createElements(from text: String,
                                            for type: ActiveType,
                                                range: NSRange,
                                                minLength: Int = 2,
                                                filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {

        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    private static func createElementsIgnoringFirstCharacter(from text: String,
                                                                  for type: ActiveType,
                                                                      range: NSRange,
                                                                      filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 0 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("$") {
                word.remove(at: word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
}

//struct ActiveBuilder {
//
//    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
//        switch type {
//        case .mention, .hashtag, .email:
//            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
//        case .url:
//            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
//        }
//    }
//
//    static func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
//        let type = ActiveType.url
//        var text = text
//        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
//        let nsstring = text as NSString
//        var elements: [ElementTuple] = []
//        var offset = 0
//        for match in matches where match.range.length > 0 {
//            let adjustedRange = NSRange(location: match.range.location + offset, length: match.range.length)
//            let word = nsstring.substring(with: adjustedRange).trimmingCharacters(in: .whitespacesAndNewlines)
//            guard let maxLength = maximumLength, word.count > maxLength else {
//                let element = ActiveElement.create(with: type, text: word)
//                elements.append((adjustedRange, element, type))
//                continue
//            }
//            let trimmedWord = word.trim(to: maxLength)
//            text = (text as NSString).replacingCharacters(in: adjustedRange, with: trimmedWord)
//            let trimmedLengthDifference = trimmedWord.count - word.count
//            offset += trimmedLengthDifference
//            let newRange = NSRange(location: adjustedRange.location, length: trimmedWord.count)
//            let element = ActiveElement.url(original: word, trimmed: trimmedWord)
//            elements.append((newRange, element, type))
//        }
//        return (elements, text)
//    }
//
//    private static func createElements(from text: String,
//                                       for type: ActiveType,
//                                       range: NSRange,
//                                       minLength: Int = 2,
//                                       filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
//        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
//        let nsstring = text as NSString
//        var elements: [ElementTuple] = []
//        for match in matches where match.range.length > minLength {
//            let word = nsstring.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
//            if filterPredicate?(word) ?? true {
//                let element = ActiveElement.create(with: type, text: word)
//                elements.append((match.range, element, type))
//            }
//        }
//        return elements
//    }
//
//    private static func createElementsIgnoringFirstCharacter(from text: String,
//                                                             for type: ActiveType,
//                                                             range: NSRange,
//                                                             filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
//        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
//        let nsstring = text as NSString
//        var elements: [ElementTuple] = []
//        for match in matches where match.range.length > 0 {
//            let wordRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
//            var word = nsstring.substring(with: wordRange)
//            if let firstChar = word.first, ["@", "#", "$"].contains(firstChar) {
//                word.remove(at: word.startIndex)
//            }
//            if filterPredicate?(word) ?? true {
//                let element = ActiveElement.create(with: type, text: word)
//                elements.append((match.range, element, type))
//            }
//        }
//        return elements
//    }
//}
