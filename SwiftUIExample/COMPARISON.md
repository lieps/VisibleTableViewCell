# UIKit vs SwiftUI Implementation Comparison

Detailed comparison of the UIKit and SwiftUI implementations of automatic cell focus detection.

## Architecture Comparison

### UIKit (ViewController.swift)

```
ViewController
├── UITableView
│   ├── UITableViewDataSource
│   ├── UITableViewDelegate
│   └── Custom XIB Cell
├── scrollViewDidEndDragging
├── scrollViewDidEndDecelerating
└── visibleCellsInfo() [Core Algorithm]
```

### SwiftUI iOS 14+ (ContentView.swift)

```
ContentView
├── ScrollView + LazyVStack
├── GeometryReader (scroll tracking)
├── PreferenceKey (data flow)
├── VisibleCellView (per-cell tracking)
└── detectFocusedCell() [Core Algorithm]
```

### SwiftUI iOS 17+ (ContentView_iOS17.swift)

```
ContentView_iOS17
├── ScrollView + LazyVStack
├── scrollTargetLayout()
├── scrollTargetBehavior(.viewAligned)
└── scrollPosition(id:) [Built-in tracking]
```

## Code Mapping

### Scroll Event Detection

**UIKit:**
```swift
func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
        self.visibleCellsInfo()
    }
}

func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.visibleCellsInfo()
}
```

**SwiftUI iOS 14+:**
```swift
.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
    handleScrollOffsetChange(value)
}

private func handleScrollOffsetChange(_ offset: CGFloat) {
    isScrolling = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        if abs(scrollOffset - offset) < 0.5 {
            isScrolling = false
            detectFocusedCell()
        }
    }
}
```

**SwiftUI iOS 17+:**
```swift
.scrollPosition(id: $scrollPosition)
.onChange(of: scrollPosition) { oldValue, newValue in
    handleFocusChange(from: oldValue, to: newValue)
}
```

### Visible Cells Query

**UIKit:**
```swift
for cell in self.tableView.visibleCells.enumerated() {
    let diff = cell.element.frame.origin.y - tableView.contentOffset.y
    // ...
}
```

**SwiftUI iOS 14+:**
```swift
// Each cell reports itself via PreferenceKey
GeometryReader { geometry in
    Color.clear
        .preference(
            key: DetailedCellVisibilityPreferenceKey.self,
            value: [calculateVisibility(geometry: geometry)]
        )
}

.onPreferenceChange(DetailedCellVisibilityPreferenceKey.self) { data in
    cellVisibilityData = data
}
```

**SwiftUI iOS 17+:**
```swift
// Automatic - no manual tracking needed
.scrollPosition(id: $scrollPosition)
```

### Visibility Calculation

**UIKit:**
```swift
let diff = cell.element.frame.origin.y - tableView.contentOffset.y

// First cell
if cell.offset == 0 {
    totalValue = cellHeight - Double(abs(diff))
    firstItem = floor((totalValue*100)/cellHeight)
}

// Last cell
else if cell.offset == (tableView.visibleCells.count-1) {
    let h = cellHeight-(totalValue - Double(tableView.frame.height))
    lastItem = floor((h*100)/cellHeight)
}
```

**SwiftUI iOS 14+:**
```swift
private func calculateVisibility(geometry: GeometryProxy) -> CellVisibilityData {
    let frame = geometry.frame(in: .named("scrollView"))
    let scrollViewHeight: CGFloat = UIScreen.main.bounds.height

    let visibleTop = max(0, frame.minY)
    let visibleBottom = min(scrollViewHeight, frame.maxY)
    let visibleHeight = max(0, visibleBottom - visibleTop)

    let percentage = (visibleHeight / cellHeight) * 100

    return CellVisibilityData(index: index, visiblePercentage: percentage, ...)
}
```

**SwiftUI iOS 17+:**
```swift
// Automatic - handled by system
```

### Focus Application

**UIKit:**
```swift
if let focusCell = self.tableView.cellForRow(at: focusIndex!) as? VisibleTableViewCell {
    focusCell.layer.borderWidth = 1
    focusCell.layer.borderColor = UIColor.red.cgColor

    DispatchQueue.main.asyncAfter(deadline: .now()+0) {
        focusCell.lblText.text = "focus on"
    }
}
```

**SwiftUI (both versions):**
```swift
VisibleCellView(
    item: items[index],
    index: index,
    isFocused: focusedIndex == index  // Reactive binding
)

// In cell view:
.overlay(
    RoundedRectangle(cornerRadius: 0)
        .stroke(isFocused ? Color.red : Color.clear, lineWidth: isFocused ? 2 : 0)
        .animation(.easeInOut(duration: 0.3), value: isFocused)
)

Text(isFocused ? "focus on" : "out of focus")
```

## Line Count Comparison

| Implementation | Lines of Code | Complexity |
|---------------|---------------|------------|
| UIKit (ViewController.swift) | ~165 | Medium |
| SwiftUI iOS 14+ (All files) | ~300 | High |
| SwiftUI iOS 17+ (All files) | ~150 | Low |

*Note: SwiftUI iOS 14+ is longer due to manual tracking infrastructure*

## Feature Parity

| Feature | UIKit | SwiftUI 14+ | SwiftUI 17+ |
|---------|-------|-------------|-------------|
| Scroll tracking | ✅ Native | ✅ Manual | ✅ Native |
| Visibility % | ✅ Manual | ✅ Manual | ✅ Automatic |
| Focus detection | ✅ Manual | ✅ Manual | ✅ Automatic |
| Visual feedback | ✅ | ✅ | ✅ |
| Animations | ⚠️ Limited | ✅ Full | ✅ Full |
| Debug logging | ✅ | ✅ | ⚠️ Simplified |
| Cell reuse | ✅ Automatic | ✅ Automatic | ✅ Automatic |

## Performance

### Memory Usage

- **UIKit**: Most efficient (direct cell reuse)
- **SwiftUI 14+**: Good (LazyVStack with PreferenceKey overhead)
- **SwiftUI 17+**: Excellent (optimized by system)

### Scroll Performance

- **UIKit**: 60fps constant
- **SwiftUI 14+**: 60fps (may drop during heavy PreferenceKey updates)
- **SwiftUI 17+**: 60fps constant (native optimization)

### Calculation Overhead

- **UIKit**: Minimal (runs once per scroll stop)
- **SwiftUI 14+**: Higher (PreferenceKey propagation + debouncing)
- **SwiftUI 17+**: Minimal (system-level tracking)

## Advantages & Disadvantages

### UIKit

**Advantages:**
- Mature, battle-tested API
- Direct control over cell lifecycle
- Precise frame calculations
- No additional abstractions

**Disadvantages:**
- More boilerplate code
- Manual memory management considerations
- XIB/Storyboard complexity
- Imperative style harder to maintain

### SwiftUI iOS 14+

**Advantages:**
- Declarative syntax
- Automatic view updates
- Type-safe state management
- Cross-platform potential

**Disadvantages:**
- Complex PreferenceKey setup
- Debouncing needed for scroll stop
- More code than UIKit for this use case
- Performance overhead from PreferenceKeys

### SwiftUI iOS 17+

**Advantages:**
- Simplest implementation
- Native scroll tracking
- Best performance in SwiftUI
- Minimal code
- Automatic snapping behavior

**Disadvantages:**
- iOS 17+ only (limits compatibility)
- Less control over exact algorithm
- May not match UIKit behavior exactly

## Migration Path

### From UIKit to SwiftUI iOS 14+

1. Replace `UITableView` with `ScrollView` + `LazyVStack`
2. Create `PreferenceKey` for scroll tracking
3. Convert `visibleCellsInfo()` to `detectFocusedCell()`
4. Use `@State` for focus tracking
5. Replace XIB with SwiftUI View

**Difficulty:** Medium-High
**Time estimate:** 4-8 hours

### From UIKit to SwiftUI iOS 17+

1. Replace `UITableView` with `ScrollView` + `LazyVStack`
2. Add `.scrollTargetLayout()` and `.scrollTargetBehavior()`
3. Use `.scrollPosition()` for tracking
4. Convert cell to SwiftUI View

**Difficulty:** Low-Medium
**Time estimate:** 2-4 hours

## When to Use Each

### Use UIKit when:
- Targeting iOS < 14
- Need precise control over scroll behavior
- Working in existing UIKit codebase
- Performance is absolutely critical

### Use SwiftUI iOS 14+ when:
- Targeting iOS 14-16
- Want declarative UI
- Building new features in SwiftUI app
- Can tolerate slight performance overhead

### Use SwiftUI iOS 17+ when:
- Can target iOS 17+
- Want simplest implementation
- Don't need exact UIKit algorithm
- Prefer native snapping behavior

## Conclusion

All three implementations achieve the same user-facing behavior:
1. Scroll through cells
2. Stop scrolling
3. Most visible cell is highlighted

The best choice depends on:
- **iOS version support needed**
- **Existing codebase (UIKit vs SwiftUI)**
- **Performance requirements**
- **Development time available**
- **Algorithm precision requirements**

For new projects in 2024+, **SwiftUI iOS 17+** is recommended for its simplicity and native optimization.
