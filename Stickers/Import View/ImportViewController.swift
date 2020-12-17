//
//  ImportViewController.swift
//  Stickers
//
//  Created by Timothy Park on 7/17/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class ImportViewController: NSViewController {
    
    var pasteboard = NSPasteboard.general
    
    weak var image: NSImage? {
        didSet {
            if let image = image {
                imageOverlay.image = image
            }
        }
    }
    
    var color: NSColor = .white {
        didSet {
            imageOverlay.color = color
        }
    }
    
    var width: CGFloat = GlobalSettings.borderWidth * 2 {
        didSet {
            imageOverlay.thickness = width
        }
    }
    
    lazy var imageOverlay: ImageView = {
        var imageOverlay = ImageView()
        imageOverlay.translatesAutoresizingMaskIntoConstraints = false
        imageOverlay.wantsLayer = true
        imageOverlay.layer?.masksToBounds = true
        imageOverlay.imageScaling = .scaleProportionallyUpOrDown
        imageOverlay.layer?.contentsGravity = .resize
        return imageOverlay
    }()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 530, height: 530))
        view.wantsLayer = true
        view.layer?.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageOverlay)
        imageOverlay.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageOverlay.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let viewOverlayConstraints = [
            imageOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            imageOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(viewOverlayConstraints)
        
        print("loading")
        print(image == nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        resetLayers()
        setMode(mode: DrawMode(rawValue: GlobalSettings.drawMode)!)
        setBorderWidth(newWidth: GlobalSettings.borderWidth * 2)
        // view.window?.contentAspectRatio = imageOverlay.image!.size
        // preferredContentSize = imageOverlay.imageRect().size
        // view.frame.size = imageOverlay.imageRect().size
        // preferredContentSize = imageOverlay.imageRect().size
        view.window?.contentAspectRatio = imageOverlay.image!.size
    }
    
    func setMode(mode: DrawMode) {
        imageOverlay.mode = mode
        imageOverlay.needsDisplay = true
    }
    
    func setBorderWidth(newWidth: CGFloat) {
        width = newWidth
        imageOverlay.thickness = newWidth
    }
    
    func resetLayers() {
        imageOverlay.resetAllLayers()
    }
    
    func presentSaveAlert() {
        imageOverlay.renderImage { (success) in
            guard let resultingImage = imageOverlay.resultImage else { return }
            let resizedImage = resultingImage.withTransparentBorder(insets: NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)).resizedTo(width: 100)
            // print(resizedImage.size)
            let a = NSAlert()
            a.messageText = "Save this sticker?"
            a.informativeText = "Select the collection to place it in."
            a.icon = resultingImage
            let popUpButton = NSPopUpButton()
            if let collectionsList = FileManagerController.shared?.getCollectionsList() {
                popUpButton.addItems(withTitles: collectionsList)
            }
            a.accessoryView = popUpButton
            a.accessoryView?.setFrameSize(NSSize(width: 125, height: 30))
            a.addButton(withTitle: "Save Sticker")
            a.addButton(withTitle: "Cancel")
            a.alertStyle = .informational
            var w: NSWindow?
            if let window = view.window {
                w = window
            } else if let window = NSApplication.shared.windows.first {
                w = window
            }
            if let window = w {
                a.beginSheetModal(for: window) { [weak self] (modalResponse) in
                    guard let strongSelf = self else { return }
                    if modalResponse == .alertFirstButtonReturn {
                        let uuid = NSUUID().uuidString.lowercased()
                        guard let path = (a.accessoryView as! NSPopUpButton).titleOfSelectedItem else { return }
                        if let collection = FileManagerController.shared?.collectionsURL.appendingPathComponent(path, isDirectory: true) {
                            resizedImage.writePNG(toURL: collection.appendingPathComponent(uuid + ".png"))
                        }
                        w = nil
                        strongSelf.view.window?.fadeOut(sender: self, duration: 0.25)
                        NSColorPanel.shared.close()
                    }
                }
            }
        }
    }
    
    func viewWindowCloses() {
        imageOverlay.resetAllLayers()
        imageOverlay.layer?.mask = nil
        imageOverlay.image = nil
        imageOverlay.resultImage = nil
    }
    
}
