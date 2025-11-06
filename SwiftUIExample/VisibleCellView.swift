//
//  VisibleCellView.swift
//  SwiftUI Visible Cell Example
//
//  Custom cell view that reports its visibility
//

import SwiftUI

struct VisibleCellView: View {
    let item: String
    let index: Int
    let isFocused: Bool
    let cellHeight: CGFloat = 260

    var body: some View {
        ZStack {
            // Cell content
            VStack(spacing: 16) {
                Text(item)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Text(isFocused ? "focus on" : "out of focus")
                    .font(.system(size: 16))
                    .foregroundColor(isFocused ? .green : .gray)
                    .animation(.easeInOut(duration: 0.3), value: isFocused)

                // Debug info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Index: \(index)")
                    Text("Height: \(Int(cellHeight))pt")
                }
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .frame(height: cellHeight)
        .overlay(
            // Focus border
            RoundedRectangle(cornerRadius: 0)
                .stroke(isFocused ? Color.red : Color.clear, lineWidth: isFocused ? 2 : 0)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
        )
        .background(
            // Visibility tracking
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: DetailedCellVisibilityPreferenceKey.self,
                        value: [calculateVisibility(geometry: geometry)]
                    )
            }
        )
    }

    /// Calculate the visible percentage of this cell
    private func calculateVisibility(geometry: GeometryProxy) -> CellVisibilityData {
        let frame = geometry.frame(in: .named("scrollView"))

        // Get the scroll view bounds (assuming it's the screen height minus safe areas)
        // In practice, you'd pass this in or calculate it more precisely
        let scrollViewHeight: CGFloat = UIScreen.main.bounds.height

        // Calculate visible height
        let visibleTop = max(0, frame.minY)
        let visibleBottom = min(scrollViewHeight, frame.maxY)
        let visibleHeight = max(0, visibleBottom - visibleTop)

        // Calculate percentage
        let percentage = (visibleHeight / cellHeight) * 100

        return CellVisibilityData(
            index: index,
            visiblePercentage: percentage,
            frameInScrollView: frame
        )
    }
}

// Preview
struct VisibleCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            VisibleCellView(item: "Cell 0", index: 0, isFocused: false)
            VisibleCellView(item: "Cell 1", index: 1, isFocused: true)
            VisibleCellView(item: "Cell 2", index: 2, isFocused: false)
        }
    }
}
