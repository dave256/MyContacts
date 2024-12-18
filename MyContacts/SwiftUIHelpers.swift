//
//  SwiftUIHelpers.swift
//  MyContacts
//
//  Created by David Reed on 1/6/23.
//

import SwiftUI

typealias UpdateWidthFunction = ((CGFloat?) -> Void)
typealias UpdateHeightFunction = ((CGFloat?) -> Void)
typealias UpdateSizeFunction = ((CGSize) -> Void)


// MARK: - PreferenceKeys

/// PreferenceKey for MaxWidthPreferenceModifier
struct MaxWidthPreference: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        // if no new value, nothing to change
        guard let next = nextValue() else {
            return
        }
        // update to max of existing value and new value
        value = max(value ?? next, next)
    }
}

/// PreferenceKey for MaxHeightPreferenceModifier
struct MaxHeightPreference: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        // if no new value, nothing to change
        guard let next = nextValue() else {
            return
        }
        // update to max of existing value and new value
        value = max(value ?? next, next)
    }
}

/// PreferenceKey for SizeReaderPreferenceModifier
struct SizeReaderPreference: PreferenceKey {
    static var defaultValue: CGSize? = nil

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        // if no new value, nothing to change
        guard let next = nextValue() else {
            return
        }
        // update to last value
        value = next
    }
}


// MARK: - ViewModifiers

/// used for View extension `sharedWidthUsingMax(updateWidth: @escaping UpdateWidthFunction)`
struct MaxWidthPreferenceModifier: ViewModifier {
    /// function that is called with the updated width as its parameter
    var updateWidth: UpdateWidthFunction?

    func body(content: Content) -> some View {
        // use overlay since otherwise GeometryReader takes all available space
        content.overlay(GeometryReader { geometry in
            // set the preference to the width of the content view
            Color.clear.preference(key: MaxWidthPreference.self, value: geometry.size.width)
        })
        .onPreferenceChange(MaxWidthPreference.self) { updateWidth?($0) }
    }
}

/// used for View extension `sharedHeightUsingMax(updateHeight: @escaping UpdateHeightFunction)`
struct MaxHeightPreferenceModifier: ViewModifier {
    /// function that is called with the updated height as its parameter
    var updateHeight: UpdateHeightFunction?

    func body(content: Content) -> some View {
        // use overlay since otherwise GeometryReader takes all available space
        content.overlay(GeometryReader { geometry in
            // set the preference to the height of the content view
            Color.clear.preference(key: MaxHeightPreference.self, value: geometry.size.height)
        })
        .onPreferenceChange(MaxHeightPreference.self) { updateHeight?($0) }
    }
}

// used for View extension `sizeReader(sizeReader: @escaping UpdateSizeFunction)`
struct SizeReaderPreferenceModifier: ViewModifier {
    /// function that is called with the updated size (if the size is not nil)
    var updateSize: UpdateSizeFunction?

    func body(content: Content) -> some View {
        // use overlay since otherwise GeometryReader takes all available space
        content.overlay(GeometryReader { geometry in
            // set the preference to the size of the content view
            Color.clear.preference(key: SizeReaderPreference.self, value: geometry.size)
        })
        .onPreferenceChange(SizeReaderPreference.self) {
            // only update if not nil
            if let size = $0 {
                updateSize?(size)
            }
        }
    }
}


// MARK: - View extensions

extension View {

    /**
     use this on views in a HStack that you want to have the same width (max width of each item)
     - Parameter updateWidth: function that is called with the updated width
     - Returns: modified View

     example usage:
     ```
     struct SharedWidthCellDemo: View {
         // the sharedWidth set to use for all the Cell views in a VStack
         var sharedWidth: CGFloat? = 0

         var body: some View {
             Text("Cell \(sharedWidth ?? 0)")
             // for demo give each row a different random height start
                 .frame(width: CGFloat(Int.random(in: 180...240)))
             // this will ensure they all have the same width since sharedWidth will be set to width of widest Cell
                 .frame(minWidth: sharedWidth)
         }
     }

     struct SharedWidthViewDemo: View {
         @State private var cellWidth: CGFloat?

         var body: some View {
             ScrollView(.horizontal) {
                 HStack {
                     ForEach(Array(1...5), id: \.self) { _ in
                         SharedWidthCellDemo(sharedWidth: cellWidth)
                             .sharedWidthUsingMax() {
                                 cellWidth = $0
                             }
                     }
                 }
             }
         }
     }
     ```
     */
    func sharedWidthUsingMax(updateWidth: @escaping UpdateWidthFunction) -> some View {
        self.modifier(MaxWidthPreferenceModifier(updateWidth: updateWidth))
    }


    /**
     use this on views in a VStack/List that you want to have the same height (max height of each item)
     - Parameter updateWidth: function that is called with the updated width
     - Returns: modified View

     example usage:
     ```
     struct SharedHeightCellDemo: View {
         // the sharedHeight set to use for all the Cell views in a VStack/List
         var sharedHeight: CGFloat? = 0

         var body: some View {
             Text("Cell Row \(sharedHeight ?? 0)")
             // for demo give each row a different random height start
                 .frame(height: CGFloat(Int.random(in: 40...70)))
             // this will ensure they all have the same height since sharedHeight will be set to height of tallest Cell
                 .frame(minHeight: sharedHeight)
         }
     }

     struct SharedHeightViewDemo: View {
         @State private var cellHeight: CGFloat?

         var body: some View {
             VStack {
                 List {
                     ForEach(Array(1...5), id: \.self) { _ in
                         SharedHeightCellDemo(sharedHeight: cellHeight)
                         // set the @State variable cell1Height to the max height of all the cells
                             .sharedHeightUsingMax() {
                                 cellHeight = $0
                             }
                     }
                 }
             }
         }
     }
     ```
     */
    func sharedHeightUsingMax(updateHeight: @escaping UpdateHeightFunction) -> some View {
        self.modifier(MaxHeightPreferenceModifier(updateHeight: updateHeight))
    }

    /***
     use this to get the size of a view
     - Parameter sizeReader: function that is called with the update size
     - Returns: modified View

     example usage:
     ```
     struct MeasureViewDemo: View {
         @State private var size = CGSize.zero

         var body: some View {
             VStack {
                 Text("test")
                     .padding()

                 Text("width: \(self.size.width)")
                 Text("height: \(self.size.height)")
             }
             .padding(10)
             .overlay(
                 RoundedRectangle(cornerRadius: 16)
                     .stroke(Color.blue, lineWidth: 2)
             )
             .sizeReader {
                 self.size = $0
             }
         }
     }
     ```
     */
    func sizeReader(sizeReader: @escaping UpdateSizeFunction) -> some View {
        self.modifier(SizeReaderPreferenceModifier(updateSize: sizeReader))
    }
}
