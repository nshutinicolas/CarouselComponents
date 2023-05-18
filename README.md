## Carousel Components

> Started this project just to play around with different implementation of infinite carousels and I found many ways to do it and each way has the best implementation

> I will be covering those that I can document them here

### Description

### Carousel v1 aka ReusableCarousel1

> Don't the naming 😂

It is super easy to use

```swift
struct ContentView: View {
    let pages: [CustomPage] = [.init(color: .red), .init(color: .yellow), .init(color: .blue), .init(color: .pink), .init(color: .orange)]
    var body: some View {
        ReusableInfiniteCarousel1(pages: pages, showPageControls: true, pageControlOffset: -20) { page in
            RoundedRectangle(cornerRadius: 25)
                .fill(page.color)
        }
    }
}
```
It assumes that the views will be uniform for all tabs

**Implementation**

It was implemented with the usage of `PreferenceKey`.
Preference keys are a powerfull tool used in swiftUI to pass data from child level to parent level contrary to what we normally do, where we pass data from parent to child level.

**pages** takes in a model that conforms to `CustomIdentifiable` to take advantage of `customId`.

**Logic**

When the views are passed in, a new array is created that duplicated the first and last pages/view of the original array and changes their customId.

The custom preference key is used to observe the change in minX value of each view and sets it as offset.

To be continued...

**Lesson**

Usage of PreferenceKey to manupulate views

### Author

Yours truly **Nicolas Nshuti**

### Links

> I will be documenting all the links I used here for easy accessibility
