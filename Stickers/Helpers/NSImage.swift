//
//  NSImage.swift
//  Stickers
//
//  Created by Timothy Park on 7/16/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

public extension NSImage {
    
    func colorized(with color: NSColor = .white) -> NSImage {
        let colored = NSImage(size: size)
        let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil,
                                        pixelsWide: Int(size.width),
                                        pixelsHigh: Int(size.height),
                                        bitsPerSample: 8,
                                        samplesPerPixel: 4,
                                        hasAlpha: true,
                                        isPlanar: false,
                                        colorSpaceName: .deviceRGB,
                                        bitmapFormat: .alphaFirst,
                                        bytesPerRow: 0,
                                        bitsPerPixel: 0)
        colored.addRepresentation(rep!)
        // colored.lockFocus()
        colored.lockFocusFlipped(true)
        
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // ctx!.clear(rect)
        color.setFill()
        // ctx!.setFillColor(color.cgColor)
        ctx!.translateBy(x: 0, y: size.height)
        ctx!.scaleBy(x: 1.0, y: -1.0)
        ctx!.clip(to: rect, mask: cgImage!)
        ctx!.fill(rect)
        ctx?.restoreGState()
        
        colored.unlockFocus()
        return colored
    }
    
    func stroked(with color: NSColor = .white, thickness: CGFloat = 2, quality: CGFloat = 10) -> NSImage {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("LOL")
            return self
        }
        // Colorize the stroke image to reflect border color
        let strokeImage = colorized(with: color)
        guard let strokeCGImage = strokeImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("WTF")
            return self
        }

        /// Rendering quality of the stroke
        let step = quality == 0 ? 10 : abs(quality)

        let oldRect = CGRect(x: thickness, y: thickness, width: size.width, height: size.height).integral
        let newSize = CGSize(width: size.width + 2 * thickness, height: size.height + 2 * thickness)
        let translationVector = CGPoint(x: thickness, y: 0)
        
        let image = NSImage(size: newSize)
        let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil,
                                        pixelsWide: Int(newSize.width),
                                        pixelsHigh: Int(newSize.height),
                                        bitsPerSample: 8,
                                        samplesPerPixel: 4,
                                        hasAlpha: true,
                                        isPlanar: false,
                                        colorSpaceName: .deviceRGB,
                                        bitmapFormat: .alphaFirst,
                                        bytesPerRow: 0,
                                        bitsPerPixel: 0)
        
        image.addRepresentation(rep!)
        // image.lockFocus()
        image.lockFocusFlipped(true)
        
        let ctx = NSGraphicsContext.current?.cgContext
        ctx!.saveGState()
        
        // context.translateBy(x: 0, y: size.height + 2 * thickness)
        ctx!.translateBy(x: 0, y: newSize.height)
        ctx!.scaleBy(x: 1.0, y: -1.0)
        ctx!.interpolationQuality = .high

        for angle: CGFloat in stride(from: 0, to: 360, by: step) {
            let vector = translationVector.rotate(around: .zero, with: angle)
            let transform = CGAffineTransform(translationX: vector.x, y: vector.y)
            ctx!.concatenate(transform)
            ctx!.draw(strokeCGImage, in: oldRect)
            let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
            ctx!.concatenate(resetTransform)
        }

        ctx!.draw(cgImage, in: oldRect)
        ctx!.restoreGState()
        
        image.unlockFocus()
        return image
    }
    
    func withTransparentBorder(insets: NSEdgeInsets) -> NSImage {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
        print(size.width, size.height)
        let newSize = CGSize(width: size.width + insets.left * 2, height: size.height + insets.top * 2)
        let imageWithBorder = NSImage(size: NSSize(width: newSize.width, height: newSize.height))
        let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bitmapFormat: .alphaFirst, bytesPerRow: 0, bitsPerPixel: 0)
        let origin = CGPoint(x: insets.left, y: insets.top)
        
        imageWithBorder.lockFocus()
        imageWithBorder.addRepresentation(rep!)
        
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        ctx!.draw(cgImage, in: CGRect(origin: origin, size: size))
        // ctx!.clear(rect)
        // color.setFill()
        // ctx!.setFillColor(color.cgColor)
        // ctx!.translateBy(x: 0, y: size.height)
        // ctx!.scaleBy(x: 1.0, y: -1.0)
        // ctx!.fill(rect)
        ctx?.restoreGState()
        imageWithBorder.unlockFocus()
        return imageWithBorder
    }
    
    func writePNG(toURL url: URL) {
        guard let data = tiffRepresentation,
            let rep = NSBitmapImageRep(data: data),
            let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {
                Swift.print("\(self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
                return
        }
        do {
            try imgData.write(to: url)
        } catch let error {
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
    
}

extension NSImage {
    
    /// Returns the height of the current image.
    var height: CGFloat {
        return self.size.height
    }
    
    /// Returns the width of the current image.
    var width: CGFloat {
        return self.size.width
    }
    
    /// Returns a png representation of the current image.
    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .png, properties: [:])
        }
        
        return nil
    }
    
    ///  Copies the current image and resizes it to the given size.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The resized copy of the given image.
    func copy(size: NSSize) -> NSImage? {
        // Create a new rect with given width and height
        let frame = NSMakeRect(0, 0, size.width, size.height)
        
        // Get the best representation for the given size.
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        
        // Create an empty image with the given size.
        let img = NSImage(size: size)
        
        // Set the drawing context and make sure to remove the focus before returning.
        img.lockFocus()
        defer { img.unlockFocus() }
        
        // Draw the new image
        if rep.draw(in: frame) {
            return img
        }
        
        // Return nil in case something went wrong.
        return nil
    }
    
    ///  Copies the current image and resizes it to the size of the given NSSize, while
    ///  maintaining the aspect ratio of the original image.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The resized copy of the given image.
    func resizeWhileMaintainingAspectRatioToSize(size: NSSize) -> NSImage? {
        let newSize: NSSize
        
        let widthRatio  = size.width / self.width
        let heightRatio = size.height / self.height
        
        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(self.width * widthRatio), height: floor(self.height * widthRatio))
        } else {
            newSize = NSSize(width: floor(self.width * heightRatio), height: floor(self.height * heightRatio))
        }
        
        return self.copy(size: newSize)
    }
    
    ///  Copies and crops an image to the supplied size.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The cropped copy of the given image.
    func crop(size: NSSize) -> NSImage? {
        // Resize the current image, while preserving the aspect ratio.
        guard let resized = self.resizeWhileMaintainingAspectRatioToSize(size: size) else {
            return nil
        }
        // Get some points to center the cropping area.
        let x = floor((resized.width - size.width) / 2)
        let y = floor((resized.height - size.height) / 2)
        
        // Create the cropping frame.
        let frame = NSMakeRect(x, y, size.width, size.height)
        
        // Get the best representation of the image for the given cropping frame.
        guard let rep = resized.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        
        // Create a new image with the new size
        let img = NSImage(size: size)
        
        img.lockFocus()
        defer { img.unlockFocus() }
        
        if rep.draw(in: NSMakeRect(0, 0, size.width, size.height),
                    from: frame,
                    operation: NSCompositingOperation.copy,
                    fraction: 1.0,
                    respectFlipped: false,
                    hints: [:]) {
            // Return the cropped image.
            return img
        }
        
        // Return nil in case anything fails.
        return nil
    }
    
    ///  Saves the PNG representation of the current image to the HD.
    ///
    /// - parameter url: The location url to which to write the png file.
    func savePNGRepresentationToURL(url: URL) throws {
        if let png = self.PNGRepresentation {
            try png.write(to: url, options: .atomicWrite)
        }
    }
}

extension NSImage {

    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
    }

    func resizedTo(width: CGFloat, height: CGFloat) -> NSImage {
        let ratioX = width / size.width
        let ratioY = height / size.height
        let ratio = ratioX < ratioY ? ratioX : ratioY
        let canvasSize = NSSize(width: size.width * ratio, height: size.height * ratio)
        let img = NSImage(size: canvasSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: CGPoint(x: (canvasSize.width - (size.width * ratio)) / 2, y: (canvasSize.height - (size.height * ratio)) / 2), size: canvasSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1)
        img.unlockFocus()
        return img
    }

    func resizedTo(percentage: CGFloat) -> NSImage {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        let img = NSImage(size: canvasSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: canvasSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1)
        img.unlockFocus()
        return img
    }

    func resizedTo(width: CGFloat) -> NSImage {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let img = NSImage(size: canvasSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: canvasSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1)
        img.unlockFocus()
        return img
    }

    func scaledCopy(sizeOfLargerSide: CGFloat) ->  NSImage {
        var newW: CGFloat
        var newH: CGFloat
        var scaleFactor: CGFloat

        if ( self.size.width > self.size.height) {
            scaleFactor = self.size.width / sizeOfLargerSide
            newW = sizeOfLargerSide
            newH = self.size.height / scaleFactor
        }
        else{
            scaleFactor = self.size.height / sizeOfLargerSide
            newH = sizeOfLargerSide
            newW = self.size.width / scaleFactor
        }

        return resizedCopy(w: newW, h: newH)
    }


    func resizedCopy(w: CGFloat, h: CGFloat) -> NSImage {
        let destSize = NSMakeSize(w, h)
        let newImage = NSImage(size: destSize)

        newImage.lockFocus()

        self.draw(in: NSRect(origin: .zero, size: destSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: CGFloat(1)
        )

        newImage.unlockFocus()

        guard let data = newImage.tiffRepresentation,
              let result = NSImage(data: data)
        else { return NSImage() }

        return result
    }

}
