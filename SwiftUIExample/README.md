# SwiftUI Visible Cell Example

SwiftUI implementation of automatic cell focus detection - detects and highlights the most visible cell when scrolling stops.

## Overview

This is a SwiftUI port of the UIKit example in this repository. It demonstrates how to:
- Track scroll position in SwiftUI
- Calculate cell visibility percentages
- Automatically focus on the most visible cell after scrolling
- Implement the same behavior with modern iOS 17+ APIs

## Files

### Core Implementation (iOS 14+)

- **`ContentView.swift`** - Main view with manual scroll tracking and focus detection
- **`VisibleCellView.swift`** - Custom cell component with visibility reporting
- **`ScrollOffsetPreferenceKey.swift`** - PreferenceKey utilities for scroll tracking
- **`VisibleCellApp.swift`** - App entry point

### Modern Implementation (iOS 17+)

- **`ContentView_iOS17.swift`** - Simplified version using `scrollTargetBehavior`

## How It Works

### iOS 14+ Implementation

The iOS 14+ implementation manually tracks scroll events and cell visibility:

1. **Scroll Tracking**: Uses `GeometryReader` and `PreferenceKey` to monitor scroll offset
2. **Visibility Calculation**: Each cell reports its visible percentage using coordinate spaces
3. **Focus Detection**: When scrolling stops (debounced), calculates which cell is most visible:
   - First cell: calculates visible percentage from top
   - Middle cells: always 100% visible
   - Last cell: calculates visible percentage from bottom
   - Focuses on first cell with ≥90% visibility
4. **Visual Feedback**: Adds red border and "focus on" text to focused cell

### iOS 17+ Implementation

The iOS 17+ version is much simpler using new ScrollView APIs:

```swift
ScrollView {
    LazyVStack {
        ForEach(items.indices, id: \.self) { index in
            CellView(...)
                .id(index)
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
.scrollPosition(id: $scrollPosition)
```

- **`scrollTargetLayout()`**: Marks cells as scroll targets
- **`scrollTargetBehavior(.viewAligned)`**: Automatically snaps to cells
- **`scrollPosition(id:)`**: Tracks which cell is focused

## Usage

### Option 1: iOS 14+ Compatible Version

1. Create a new SwiftUI project in Xcode
2. Copy all files from `SwiftUIExample/` to your project
3. Set deployment target to iOS 14.0 or later
4. Use `ContentView` as your main view

### Option 2: iOS 17+ Only

1. Create a new SwiftUI project in Xcode
2. Copy these files:
   - `VisibleCellApp.swift`
   - `ContentView_iOS17.swift`
3. Set deployment target to iOS 17.0 or later
4. In `VisibleCellApp.swift`, change `ContentView()` to `ContentView_iOS17()`

## Key Features

- 10 sample cells, each 260pt tall
- Automatic focus detection on scroll stop
- Visual indicators (red border, focus text)
- Debug logging to console
- Smooth animations
- 100pt bottom padding (like UIKit version)

## Algorithm

The focus detection algorithm (replicating UIKit version):

```swift
for each visible cell:
    if first cell:
        calculate visible percentage from top
        set as focus candidate
    else if last cell:
        calculate visible percentage from bottom
        if first cell < 90% visible:
            set last cell as focus
    else (middle cell):
        100% visible
        if previous focus < 90%:
            set this cell as focus
```

## Comparison with UIKit Version

| Feature | UIKit | SwiftUI (iOS 14+) | SwiftUI (iOS 17+) |
|---------|-------|-------------------|-------------------|
| Scroll tracking | `scrollViewDidEndDecelerating` | PreferenceKey + debounce | `scrollPosition` |
| Visibility calc | Manual frame math | GeometryReader + coordinate space | Automatic |
| Focus detection | Manual algorithm | Same algorithm | Automatic |
| Code complexity | Medium | High | Low |
| Performance | Excellent | Good | Excellent |

## Debug Output

When scrolling stops, the console shows:

```
-----visibleCellsInfo-----
Visible Indices: [2, 3, 4]
Scroll Offset: -520
Visible Cell Count: 3
--------------------------
INDEX       PERCENTAGE
F [0] index: 2      85%
M [1] index: 3      100%
L [2] index: 4      73%
Focus: index 3, 100%
Previous cell: 2
Changed cell: 3
```

## Requirements

- **iOS 14+** for `ContentView.swift` implementation
- **iOS 17+** for `ContentView_iOS17.swift` implementation
- Xcode 15+ recommended
- Swift 5.9+

## License

Same as the parent repository (see LICENSE file)

## Original UIKit Implementation

See the `visibleTableViewCellExam` folder for the original UIKit implementation.

## Tips

- For production apps targeting iOS 17+, use `ContentView_iOS17.swift` - it's simpler and more performant
- For backwards compatibility, use `ContentView.swift`
- Adjust `focusThreshold` (default 90%) to change focus sensitivity
- Modify `cellHeight` to change cell size
- Add `.safeAreaPadding()` if needed for better edge handling

## Customization

### Change Focus Threshold

```swift
private let focusThreshold: CGFloat = 80.0 // Focus on cells 80%+ visible
```

### Change Cell Height

```swift
private let cellHeight: CGFloat = 300 // Taller cells
```

### Disable Auto-focus

Comment out the focus detection in `handleScrollOffsetChange()`:

```swift
// detectFocusedCell() // Disabled
```

## Performance Notes

- Uses `LazyVStack` for efficient memory usage
- PreferenceKeys are computed only when needed
- Debouncing prevents excessive calculations
- iOS 17+ version is more efficient due to native APIs
