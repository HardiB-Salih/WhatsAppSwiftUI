//
//  CustomSlider.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

//MARK: CustomSlider
struct CustomSlider<Component: View>: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var thumbWidth: CGFloat?
    let viewBuilder: (SliderComponents) -> Component

    init(value: Binding<Double>, range: ClosedRange<Double>, thumbWidth: CGFloat? = nil,
         _ viewBuilder: @escaping (SliderComponents) -> Component
    ) {
        _value = value
        self.range = range
        self.viewBuilder = viewBuilder
        self.thumbWidth = thumbWidth
    }

    var body: some View {
        return GeometryReader { geometry in
            self.view(geometry: geometry)
        }
    }
    
    /// Constructs the view for the custom slider based on the provided geometry.
    ///
    /// - Parameter geometry: The geometry proxy representing the size and position of the slider.
    /// - Returns: A view representing the custom slider.
    private func view(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .global)
        let drag = DragGesture(minimumDistance: 0).onChanged({ drag in
            self.onDragChange(drag, frame) }
        )
        let offsetX = self.getOffsetX(frame: frame)

        let thumbSize = CGSize(width: thumbWidth ?? frame.height, height: frame.height)
        let trackLeadingSize = CGSize(width: CGFloat(offsetX + thumbSize.width * 0.5), height:  frame.height)
        let trackTrailingSize = CGSize(width: frame.width - trackLeadingSize.width, height: frame.height)

        let modifiers = SliderComponents(
            trackLeading: SliderModifier(name: .trackLeading, size: trackLeadingSize, offset: 0),
            trackTrailing: SliderModifier(name: .trackTrailing, size: trackTrailingSize, offset: trackLeadingSize.width),
            thumb: SliderModifier(name: .thumb, size: thumbSize, offset: offsetX))

        return ZStack { viewBuilder(modifiers).gesture(drag) }
    }
    
    /// Updates the slider value based on the drag gesture.
    ///
    /// - Parameters:
    ///   - drag: The value of the drag gesture.
    ///   - frame: The frame of the slider.
    private func onDragChange(_ drag: DragGesture.Value, _ frame: CGRect) {
        let width = (thumb: Double(thumbWidth ?? frame.size.height), view: Double(frame.size.width))
        let xrange = ClosedRange(uncheckedBounds: (lower: 0, upper: width.view - width.thumb))
        var value = Double(drag.startLocation.x + drag.translation.width) // knob center x
        value -= 0.5 * width.thumb // offset from center to leading edge of knob
        value = value > xrange.upperBound ? xrange.upperBound : value // limit to leading edge
        value = value < xrange.lowerBound ? xrange.lowerBound : value // limit to trailing edge
        value = value.convert(fromRange: xrange, toRange: range)
        self.value = value
    }
    
    /// Calculates the horizontal offset for the slider knob based on its current value within the specified range.
    /// - Parameters:
    ///   - frame: The frame of the slider.
    /// - Returns: The horizontal offset for the slider thumb.
    private func getOffsetX(frame: CGRect) -> CGFloat {
        let width = (thumb: thumbWidth ?? frame.size.height, view: frame.size.width)
        let xrange = 0.0...(Double(width.view - width.thumb))
        let result = self.value.convert(fromRange: range, toRange: xrange)
        return CGFloat(result)
    }
}


//MARK: -Slider Components
struct SliderComponents {
    let trackLeading: SliderModifier
    let trackTrailing: SliderModifier
    let thumb: SliderModifier
}


//MARK: -Slider Modifier
struct SliderModifier: ViewModifier {
    enum Name {
        case trackLeading
        case trackTrailing
        case thumb
    }
    let name: Name
    let size: CGSize
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
        .frame(width: size.width)
        .position(x: size.width*0.5, y: size.height*0.5)
        .offset(x: offset)
    }
}


//MARK: -Double
extension Double {
    func convert(fromRange: ClosedRange<Double>, toRange: ClosedRange<Double>) -> Double {
        var value = self
        value -= fromRange.lowerBound
        value /= fromRange.upperBound - fromRange.lowerBound
        value *= toRange.upperBound - toRange.lowerBound
        value += toRange.lowerBound
        return value
    }
}

