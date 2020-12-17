//
//  NSWindow.swift
//  Stickers
//
//  Created by Timothy Park on 7/23/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

private let defaultWindowAnimationDuration: TimeInterval = 0.25

// https://gist.github.com/BenLeggiero/1ec89e5979bf88ca13e2393fdab15ecc
public extension NSWindow {
    
    /// Called when an animation completes
    typealias AnimationCompletionHandler = () -> Void
    
    /// Represents a function called to make a window be presented
    enum PresentationFunction {
        /// Calls `NSWindow.makeKey()`
        case makeKey
        
        /// Calls `NSWindow.makeKeyAndOrderFront(_:)`
        case makeKeyAndOrderFront
        
        /// Calls `NSWindow.orderFront(_:)`
        case orderFront
        
        /// Calls `NSWindow.orderFrontRegardless()`
        case orderFrontRegardless
        
        
        /// Runs the function represented by this case on the given window, passing the given selector if needed
        public func run(on window: NSWindow, sender: Any?) {
            switch self {
            case .makeKey: window.makeKey()
            case .makeKeyAndOrderFront: window.makeKeyAndOrderFront(sender)
            case .orderFront: window.orderFront(sender)
            case .orderFrontRegardless: window.orderFrontRegardless()
            }
        }
    }
    
    /// Represents a function called to make a window be closed
    enum CloseFunction {
        /// Calls `NSWindow.orderOut(_:)`
        case orderOut
        
        /// Calls `NSWindow.close()`
        case close
        
        /// Calls `NSWindow.performClose()`
        case performClose
        
        
        /// Runs the function represented by this case on the given window, passing the given selector if needed
        public func run(on window: NSWindow, sender: Any?) {
            switch self {
            case .orderOut: window.orderOut(sender)
            case .close: window.close()
            case .performClose: window.performClose(sender)
            }
        }
    }
    
    /// Fades this window in using the given configuration
    ///
    /// - Parameters:
    ///   - sender:               The message's sender, if any
    ///   - duration:             The minimum amount of time it should to fade the window in
    ///   - timingFunction:       The timing function of the animation
    ///   - startingAlpha:        The alpha value at the start of the animation
    ///   - targetAlpha:          The alpha value at the end of the animation
    ///   - presentationFunction: The function to use when initially presenting the window
    ///   - completionHandler:    Called when the animation completes
    func fadeIn(sender: Any?,
                duration: TimeInterval,
                timingFunction: CAMediaTimingFunction? = .default,
                startingAlpha: CGFloat = 0,
                targetAlpha: CGFloat = 1,
                presentationFunction: PresentationFunction = .makeKeyAndOrderFront,
                completionHandler: AnimationCompletionHandler? = nil) {
        
        alphaValue = startingAlpha
        presentationFunction.run(on: self, sender: sender)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = timingFunction
            animator().alphaValue = targetAlpha
        }, completionHandler: completionHandler)
    }
    
    /// Fades this window out using the given configuration
    ///
    /// - Note: Unlike `fadeIn`, this does not take a starting alpha value. This is because the window's current
    ///         alpha is used. If you really want it to be different, simply change that immediately before calling
    ///         this function.
    ///
    /// - Parameters:
    ///   - sender:               The message's sender, if any
    ///   - duration:             The minimum amount of time it should to fade the window out
    ///   - timingFunction:       The timing function of the animation
    ///   - targetAlpha:          The alpha value at the end of the animation
    ///   - presentationFunction: The function to use when initially presenting the window
    ///   - completionHandler:    Called when the animation completes
    func fadeOut(sender: Any?,
                 duration: TimeInterval,
                 timingFunction: CAMediaTimingFunction? = .default,
                 targetAlpha: CGFloat = 0,
                 resetAlphaAfterAnimation: Bool = true,
                 closeSelector: CloseFunction = .orderOut,
                 completionHandler: AnimationCompletionHandler? = nil) {
        
        let startingAlpha = self.alphaValue
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = timingFunction
            animator().alphaValue = targetAlpha
        }, completionHandler: { [weak weakSelf = self] in
            guard let weakSelf = weakSelf else { return }
            closeSelector.run(on: weakSelf, sender: sender)
            if resetAlphaAfterAnimation {
                weakSelf.alphaValue = startingAlpha
            }
            completionHandler?()
        })
    }
}

public extension CAMediaTimingFunction {
    static let easeIn = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    static let easeOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    static let easenInEaseOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    static let linear = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    static let `default` = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
}

extension NSWindow {
    
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
    
}

extension NSWindowController {
    
    func bringToFront() {
        guard let screenFrame = NSScreen.main?.frame, let windowSize = window?.frame.size else { return }
        window?.setFrameOrigin(NSPoint(x: (screenFrame.width - windowSize.width) / 2, y: (screenFrame.height - windowSize.height) / 2))
        window?.fadeIn(sender: self, duration: 0.12)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
