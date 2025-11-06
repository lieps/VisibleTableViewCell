//
//  ContentView_iOS17.swift
//  SwiftUI Visible Cell Example
//
//  iOS 17+ implementation using modern ScrollView APIs
//  This version is much simpler using scrollTargetBehavior
//

import SwiftUI

@available(iOS 17.0, *)
struct ContentView_iOS17: View {
    // Data
    @State private var items = (0...9).map { "Cell\($0)" }

    // Focus tracking - scrollPosition automatically tracks the focused item
    @State private var scrollPosition: Int? = nil
    @State private var previousPosition: Int? = nil

    // Configuration
    private let cellHeight: CGFloat = 260

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        SimpleCellView(
                            item: items[index],
                            index: index,
                            isFocused: scrollPosition == index
                        )
                        .id(index)
                        .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                    }
                }
                .padding(.bottom, 100)
                .scrollTargetLayout() // Enable scroll target alignment
            }
            .scrollTargetBehavior(.viewAligned) // Snap to cells
            .scrollPosition(id: $scrollPosition) // Track focused cell
            .onChange(of: scrollPosition) { oldValue, newValue in
                handleFocusChange(from: oldValue, to: newValue)
            }
            .navigationTitle("Visible Cell (iOS 17+)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Focus Change Handling

    private func handleFocusChange(from oldIndex: Int?, to newIndex: Int?) {
        guard oldIndex != newIndex else { return }

        previousPosition = oldIndex
        print("-----Focus Changed-----")
        print("Previous cell: \(oldIndex ?? -1)")
        print("Current cell: \(newIndex ?? -1)")
        print("----------------------")
    }
}

// MARK: - Simple Cell View for iOS 17+

@available(iOS 17.0, *)
struct SimpleCellView: View {
    let item: String
    let index: Int
    let isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text(item)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            Text(isFocused ? "focus on" : "out of focus")
                .font(.system(size: 16))
                .foregroundColor(isFocused ? .green : .gray)
                .animation(.easeInOut(duration: 0.3), value: isFocused)

            VStack(alignment: .leading, spacing: 4) {
                Text("Index: \(index)")
                Text("iOS 17+ scrollTargetBehavior")
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
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(isFocused ? Color.red : Color.clear, lineWidth: isFocused ? 2 : 0)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
        )
        // Smooth transitions when scrolling
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1.0 : 0.7)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
struct ContentView_iOS17_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_iOS17()
    }
}
