//
//  Extensions.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import Foundation
import IdentifiedCollections

extension IdentifiedArrayOf where Element: Comparable {

    /// find index to insert element in to maintain sorted order
    /// - Parameter element: element we want to insert
    /// - Pre: the array is already sorted
    /// - Returns: index location for insertion
    public func sortedInsertionIndexFor(_ element: Element) -> Int {
        var index = endIndex
        while index >= 1 && element < self[index - 1] {
            index -= 1
        }
        return index
    }

    /// inserts element in sorted order in the array
    /// - Parameter element: element to insert
    /// - Pre: the  array is already sorted
    public mutating func insertInSortedOrder(_ element: Element) {
        let index = sortedInsertionIndexFor(element)
        self.insert(element, at: index)
    }
}
