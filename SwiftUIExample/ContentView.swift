//
//  ContentView.swift
//  SwiftUI Visible Cell Example
//
//  Main view implementing automatic cell focus detection
//  Compatible with iOS 14+
//

import SwiftUI

struct ContentView: View {
    // Data
    @State private var items = (0...9).map { "Cell\($0)" }

    // Focus tracking
    @State private var focusedIndex: Int? = nil
    @State private var previousFocusedIndex: Int? = nil

    // Scroll tracking
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    @State private var cellVisibilityData: [CellVisibilityData] = []

    // Configuration
    private let cellHeight: CGFloat = 260
    private let focusThreshold: CGFloat = 90.0

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        VisibleCellView(
                            item: items[index],
                            index: index,
                            isFocused: focusedIndex == index
                        )
                        .id(index)
                    }
                }
                .padding(.bottom, 100) // Same as UIKit contentInset
                .background(
                    // Scroll offset tracking
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scrollView")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffsetChange(value)
            }
            .onPreferenceChange(DetailedCellVisibilityPreferenceKey.self) { data in
                cellVisibilityData = data
            }
            .navigationTitle("Visible Cell Detection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Scroll Handling

    private func handleScrollOffsetChange(_ offset: CGFloat) {
        scrollOffset = offset

        // Mark as scrolling
        isScrolling = true

        // Debounce: detect when scrolling stops
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if abs(scrollOffset - offset) < 0.5 {
                isScrolling = false
                detectFocusedCell()
            }
        }
    }

    // MARK: - Focus Detection Logic
    // This replicates the UIKit visibleCellsInfo() method

    private func detectFocusedCell() {
        guard !cellVisibilityData.isEmpty else { return }

        printDebugInfo()

        // Sort cells by index
        let sortedCells = cellVisibilityData.sorted { $0.index < $1.index }

        var focusIndex: Int?
        var focusRate: CGFloat = 0

        for (offset, cellData) in sortedCells.enumerated() {
            let percentage = cellData.visiblePercentage

            if offset == 0 {
                // First visible cell
                print("F [\(offset)] index: \(cellData.index)\t\t \(Int(percentage))%")
                focusRate = percentage
                focusIndex = cellData.index
            }
            else if offset == sortedCells.count - 1 {
                // Last visible cell
                print("L [\(offset)] index: \(cellData.index)\t\t \(Int(percentage))%")

                // If first cell is less than 90% visible, focus on next cell
                if focusRate < focusThreshold {
                    focusRate = percentage
                    focusIndex = cellData.index
                }
            }
            else {
                // Middle cells (100% visible)
                print("M [\(offset)] index: \(cellData.index)\t\t \(Int(percentage))%")

                // If previous focus is less than 90%, focus on this cell
                if focusRate < focusThreshold {
                    focusRate = 100
                    focusIndex = cellData.index
                }
            }
        }

        print("Focus: index \(focusIndex ?? -1), \(Int(focusRate))%")

        // Update focus with animation
        updateFocus(to: focusIndex)
    }

    private func updateFocus(to newIndex: Int?) {
        guard newIndex != focusedIndex else { return }

        previousFocusedIndex = focusedIndex
        focusedIndex = newIndex

        if let prev = previousFocusedIndex {
            print("Previous cell: \(prev)")
        }
        if let new = focusedIndex {
            print("Changed cell: \(new)")
        }
    }

    // MARK: - Debug

    private func printDebugInfo() {
        let visibleIndices = cellVisibilityData.map { $0.index }
        print("-----visibleCellsInfo-----")
        print("Visible Indices: \(visibleIndices)")
        print("Scroll Offset: \(Int(scrollOffset))")
        print("Visible Cell Count: \(cellVisibilityData.count)")
        print("--------------------------")
        print("INDEX\t\t PERCENTAGE")
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
