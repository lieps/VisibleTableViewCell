//
//  ScrollOffsetPreferenceKey.swift
//  SwiftUI Visible Cell Example
//
//  PreferenceKey for tracking scroll position
//

import SwiftUI

/// PreferenceKey to track scroll offset changes
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// PreferenceKey to track individual cell visibility
struct CellVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

/// Data model for cell visibility information
struct CellVisibilityData: Equatable {
    let index: Int
    let visiblePercentage: CGFloat
    let frameInScrollView: CGRect
}

/// PreferenceKey for detailed cell visibility tracking
struct DetailedCellVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [CellVisibilityData] = []

    static func reduce(value: inout [CellVisibilityData], nextValue: () -> [CellVisibilityData]) {
        value.append(contentsOf: nextValue())
    }
}
