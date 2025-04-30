//
//  TruncatedEncoding.swift
//
//
//  Created by Christopher Jr Riley on 2024-01-25.
//

import Foundation

/// A protocol that defines a method for truncating an object.
public protocol Truncatable {

    /// Truncates the object to the specified length.
    ///
    /// - Parameter length: The maximum number of items the object can have.
    /// - Returns: The truncated object.
    func truncated(toLength length: Int) -> Self
}

extension KeyedEncodingContainer {

    /// Encodes a `Truncatable & Encodable` value to a container with truncation.
    ///
    /// This is used as a replacement of `encode(_:forKey:)` if the object needs to be truncated
    /// before it's encoded.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - key: The key to associate with the encoded value.
    ///   - characterLength: The maximum length of characters a `String` value can have
    ///   before encoding. Optional. Defaults to `nil`.
    ///   - arrayLength: The maximum length of items an `Array` can have before encoding. Optional.
    ///   Defaults to `nil`.
    /// - Throws: `EncodingError.invalidValue` if the given value is invalid in the current context
    /// for this format.
    public mutating func truncatedEncode<Element: Truncatable & Encodable>(
        _ value: Element,
        forKey key: Key,
        upToCharacterLength characterLength: Int? = nil,
        upToArrayLength arrayLength: Int? = nil
    ) throws {
        if let arrayValue = value as? [Element] {
            // Truncate the array if `upToArrayLength` is specified
            var truncatedArray = arrayValue

            if let arrayLength = arrayLength {
                truncatedArray = Array(truncatedArray.prefix(arrayLength))
            }
            // Truncate each element in the array if `upToCharacterLength` is specified
            let truncatedElements = truncatedArray.map { element -> Element in
                if let characterLength = characterLength {
                    return element.truncated(toLength: characterLength)
                }

                return element
            }

            try encode(truncatedElements, forKey: key)
        } else {
            // Truncate the value if `upToCharacterLength` is specified
            var truncatedValue = value

            if let characterLength = characterLength {
                truncatedValue = truncatedValue.truncated(toLength: characterLength)
            }

            try encode(truncatedValue, forKey: key)
        }
    }

    /// Encodes an optional `Truncatable & Encodable` value to a container with truncation if the
    /// value is present.
    ///
    /// This is used as a replacement of `encodeIfPresent(_:forKey:)`  if the object needs to be
    /// truncated before it's encoded.
    ///
    /// - Parameters:
    ///   - value: The optional value to encode if present.
    ///   - key: The key to associate with the encoded value.
    ///   - characterLength: The maximum length of characters a `String` value can have
    ///   before encoding. Optional. Defaults to `nil`.
    ///   - arrayLength: The maximum length of items an `Array` can have before encoding. Optional.
    ///   Defaults to `nil`.
    /// - Throws: `EncodingError.invalidValue` if the given value is invalid in the current context
    /// for this format.
    public mutating func truncatedEncodeIfPresent<Element: Truncatable & Encodable>(
        _ value: Element?,
        forKey key: Key,
        upToCharacterLength characterLength: Int? = nil,
        upToArrayLength arrayLength: Int? = nil
    ) throws {
        if let value = value {
            if let arrayValue = value as? [Element] {
                // Truncate the array if `upToArrayLength` is specified
                var truncatedArray = arrayValue

                if let arrayLength = arrayLength {
                    truncatedArray = Array(truncatedArray.prefix(arrayLength))
                }
                // Truncate each element in the array if `upToCharacterLength` is specified
                let truncatedElements = truncatedArray.map { element -> Element in
                    if let characterLength = characterLength {
                        return element.truncated(toLength: characterLength)
                    }

                    return element
                }

                try encode(truncatedElements, forKey: key)
            } else {
                // Truncate the value if `upToCharacterLength` is specified
                var truncatedValue = value

                if let characterLength = characterLength {
                    truncatedValue = truncatedValue.truncated(toLength: characterLength)
                }

                try encode(truncatedValue, forKey: key)
            }
        }
    }
}
