//
//  Accessibility.swift
//  Stickers
//
//  Created by Timothy Park on 8/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import AppKit
import ApplicationServices

// https://github.com/jtbandes/Mojo/blob/6bf35ebe626896ec0b721985736b1c4683cfe44f/Source/Accessibility.swift
enum AXProcess {
    static func isTrusted(prompt: Bool) -> Bool {
        let opts: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): prompt]
        return AXIsProcessTrustedWithOptions(opts)
    }
}

extension AXUIElement {
    
    static let systemWide = AXUIElementCreateSystemWide()
    
    private func get<T>(_ attribute: String, as _: T.Type) -> T? {
        var result: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(self, attribute as CFString, &result)
        if err != .success {
            print("error getting \(self)[\(attribute)]: \(err.rawValue)")
        }
        return result as? T
    }
    
    private func get<T>(_ attribute: String, _ parameter: CFTypeRef, as: T.Type) -> T? {
        var result: CFTypeRef?
        let err = AXUIElementCopyParameterizedAttributeValue(self, attribute as CFString, parameter, &result)
        if err != .success {
            print("error getting \(self)[\(attribute)(\(parameter))]: \(err.rawValue)")
        }
        return result as? T
    }
    
    var focusedUIElement: AXUIElement? {
        return get(kAXFocusedUIElementAttribute, as: AXUIElement.self)
    }
    
    var processID: pid_t? {
        var pid: pid_t = 0
        return AXUIElementGetPid(self, &pid) == .success ? pid : nil
    }
    
    var selectedTextRange: CFRange? {
        return get(kAXSelectedTextRangeAttribute, as: AXValue.self)?.asRange
    }
    
    var value: String? {
        return get(kAXValueAttribute, as: CFString.self) as String?
    }
    
    func bounds(for range: CFRange) -> CGRect? {
        return get(kAXBoundsForRangeParameterizedAttribute,
                   AXValue.range(range),
                   as: AXValue.self)?.asRect
            .flatMap(NSScreen.convertFromQuartz)
    }
    
    var cursorBounds: CGRect? {
        if let selection = self.selectedTextRange, selection.length == 0 {
            // Getting the bounds for an empty range works in TextMate,
            // but not many other apps.
            // FIXME: can we get the correct bounds when RTL text is involved?
            let queryRange =
                selection.location > 0
                    ? CFRange(location: selection.location - 1, length: 1)
                    : selection
            return bounds(for: queryRange)
        }
        return nil
    }
}

extension AXValue {
    
    private func get<T>(_ type: AXValueType, initial: T) -> T? {
        var result = initial
        return AXValueGetValue(self, type, &result) ? result : nil
    }
    var asPoint: CGPoint? { return get(.cgPoint, initial: .zero) }
    var asSize: CGSize? { return get(.cgSize, initial: .zero) }
    var asRect: CGRect? { return get(.cgRect, initial: .zero) }
    var asRange: CFRange? { return get(.cfRange, initial: CFRange()) }
    var asError: AXError? { return get(.axError, initial: .success) }
    
    private static func create<T>(_ type: AXValueType, _ value: T) -> AXValue {
        var value = value
        return AXValueCreate(type, &value)!
    }
    static func point(_ v: CGPoint) -> AXValue { return create(.cgPoint, v) }
    static func size(_ v: CGSize) -> AXValue { return create(.cgSize, v) }
    static func rect(_ v: CGRect) -> AXValue { return create(.cgRect, v) }
    static func range(_ v: CFRange) -> AXValue { return create(.cfRange, v) }
    static func error(_ v: AXError) -> AXValue { return create(.axError, v) }
    
}
