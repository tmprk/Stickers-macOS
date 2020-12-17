//
//  AppDelegate.swift
//  Stickers
//
//  Created by Timothy Park on 4/17/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var statusBarMenu = NSMenu(title: "Status Bar Menu")
    
    let popover = GlobalPopover(content: PopoverController())
    let managerController = ManagerController()
    lazy var preferencesController = PreferencesController()
    lazy var importController = ImportController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarMenu.delegate = self
        createStatusItem()
        setupWindowNotifications()
        if GlobalSettings.firstRun  {
            print("Not Launched Before")
            FileManagerController.shared?.createCollectionsDirectory()
            infoAlertOnLaunch { (success) in
                if (success == false) {
                    quit()
                } else {
                    privilegesUpdates()
                }
            }
        } else {
            print("Launched Before")
            privilegesUpdates()
        }
    }
    
    func setupApplication() {
        refreshMenu()
        setupShortcuts()
    }
    
    func createStatusItem() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(named: "statusIcon")
        image?.size = NSSize(width: 20, height: 16.5)
        statusBarItem.button?.image = image
        statusBarItem.button?.isEnabled = true
    }
    
    func refreshMenu() {
        statusBarMenu.removeAllItems()
        statusBarMenu.addItem(withTitle: "Sticker From Capture", action: #selector(AppDelegate.openCaptureView), keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "Sticker From Image", action: #selector(AppDelegate.openFileSelector), keyEquivalent: "")
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(withTitle: "Sticker Manager", action: #selector(AppDelegate.openStickerManager), keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "Preferences", action: #selector(AppDelegate.openPreferences),keyEquivalent: ",")
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "q")
        statusBarItem.menu = statusBarMenu
    }
    
    func setupWindowNotifications() {
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.accessibility.api"), object: nil, queue: nil) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.privilegesUpdates()
            }
        }
    }
    
    func setupShortcuts() {
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: "popup", toAction: {
            self.popover.insertAndPopover()
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: "capture", toAction: {
            self.openCaptureView()
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: "import", toAction: {
            self.openFileSelector()
        })
    }
    
    func breakShortcutBindings() {
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: "popup")
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: "capture")
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: "import")
    }
    
    func infoAlertOnLaunch(completion: (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Welcome to Stickers!"
        alert.informativeText = "This app uses the accessibility API to copy the stickers you've made to the clipboard and paste them to other applications like iMessage, Messenger, Twitter, etc. \n\nOnce you have done so, open preferences to configure your hot-keys for showing the sticker picker and making stickers from capture."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Proceed")
        alert.addButton(withTitle: "Quit")
        if alert.runModal() == .alertSecondButtonReturn {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    func readPrivileges(prompt: Bool) -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt]
        let status = AXIsProcessTrustedWithOptions(options)
        print("Reading Accessibility privileges - Current access status:", String(status))
        return status
    }
    
    func privilegesUpdates() {
        if readPrivileges(prompt: false) {
            setupApplication()
            statusBarItem.button?.isEnabled = true
            if GlobalSettings.firstRun == true {
                openPreferences()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.statusBarItem.button?.performClick(self)
                }
                GlobalSettings.firstRun = false
            }
        } else {
            statusBarItem.button?.isEnabled = false
            breakShortcutBindings()
            _ = readPrivileges(prompt: true)
        }
    }
    
    @objc func openStickerManager() {
        managerController.bringToFront()
    }
    
    @objc func openCaptureView() {
        captureScreenRegionToClipboard { [weak self] (image) in
            guard let strongSelf = self else { return }
            strongSelf.openImportController(with: image)
        }
    }
    
    @objc func openPreferences() {
        preferencesController.bringToFront()
    }
    
    func captureScreenRegionToClipboard(completion: @escaping (NSImage) -> ()) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c", "-o"]
        task.terminationHandler = { [weak self] (task) in
            guard let strongSelf = self else { return }
            if (!task.isRunning) {
                DispatchQueue.main.async {
                    if let image = strongSelf.getImageFromClipboard() {
                        completion(image)
                    }
                }
                task.terminate()
            }
        }
        do {
            try task.run()
        } catch {
            task.terminate()
        }
        // task.launch()
        // task.waitUntilExit()
    }
    
    @objc func openFileSelector() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose an image"
        dialog.showsResizeIndicator = false
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["png", "jpg", "jpeg"]
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                if let image = NSImage(contentsOf: result!) {
                    openImportController(with: image)
                }
            }
        } else {
            print("Cancelled")
            return
        }
    }
    
    private func getImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general
        if let data = pasteboard.data(forType: .png) {
            return NSImage(data: data)
        }
        return nil
    }
    
    func copyImageToClipboard(image: NSImage, completion: (Bool) -> ()) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
        completion(true)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("com.apple.accessibility.api"), object: nil)
    }
    
    func resizeWindowUsingImage(w: CGFloat, h: CGFloat) -> NSSize {
        let aspectRatio = w / h
        if aspectRatio > 1 {
            print("width > height")
            return NSSize(width: 545, height: 545 / aspectRatio)
        } else {
            print("height > width")
            return NSSize(width: 545 * aspectRatio, height: 545)
        }
    }
    
    func openImportController(with image: NSImage) {
        importController.window?.setContentSize(resizeWindowUsingImage(w: image.width, h: image.height))
        (importController.contentViewController as! ImportViewController).image = image
        importController.bringToFront()
    }
    
}

// MARK: - NSMenuDelegate
extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        refreshMenu()
    }
    
}
