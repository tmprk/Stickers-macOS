//
//  SettingsViewController.swift
//  Stickers
//
//  Created by Timothy Park on 7/16/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa
import MASShortcut

class SettingsViewController: NSViewController {
    
    let container: NSBox = {
        let container = NSBox()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.title = "Defaults"
        return container
    }()
    
    let launchLabel = NSTextField(labelWithString: "Launch:")
    let launchAtLoginButton: NSButton = {
        let launchAtLoginButton = NSButton()
        launchAtLoginButton.translatesAutoresizingMaskIntoConstraints = false
        launchAtLoginButton.setButtonType(.switch)
        launchAtLoginButton.title = "Launch at Login"
        return launchAtLoginButton
    }()
    
    let popupLabel = NSTextField(labelWithString: "Popup Hotkey:")
    let popupShortcut = MASShortcutView()
    
    let captureHotkey = NSTextField(labelWithString: "Capture Hotkey:")
    let captureShortcut = MASShortcutView()
    
    let importHotkey = NSTextField(labelWithString: "Import Hotkey:")
    let importShortcut = MASShortcutView()
    
    let borderColorLabel = NSTextField(labelWithString: "Border Color:")
    let colorWell = NSColorWell()
    
    let borderWidthLabel = NSTextField(labelWithString: "Border Width:")
    let borderWidthSlider: NSSlider = {
        let borderWidthSlider = NSSlider()
        borderWidthSlider.translatesAutoresizingMaskIntoConstraints = false
        borderWidthSlider.minValue = 0
        borderWidthSlider.maxValue = 20
        borderWidthSlider.isContinuous = true
        borderWidthSlider.floatValue = Float(GlobalSettings.borderWidth)
        return borderWidthSlider
    }()
    
    let borderWidthValue: NSTextField = {
        let borderWidthValue = NSTextField(labelWithString: "")
        borderWidthValue.translatesAutoresizingMaskIntoConstraints = false
        borderWidthValue.textColor = .tertiaryLabelColor
        return borderWidthValue
    }()
    
    let minValueLabel: NSTextField = {
        let minValueLabel = NSTextField(labelWithString: "")
        minValueLabel.translatesAutoresizingMaskIntoConstraints = false
        minValueLabel.textColor = .tertiaryLabelColor
        minValueLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        return minValueLabel
    }()
    
    let maxValueLabel: NSTextField = {
        let maxValueLabel = NSTextField(labelWithString: "")
        maxValueLabel.translatesAutoresizingMaskIntoConstraints = false
        maxValueLabel.textColor = .tertiaryLabelColor
        maxValueLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        return maxValueLabel
    }()
    
    let permissionsLabel = NSTextField(labelWithString: "Permissions:")
    let permissionsButton: NSButton = {
        let permissionsButton = NSButton()
        permissionsButton.translatesAutoresizingMaskIntoConstraints = false
        permissionsButton.bezelStyle = .roundRect
        return permissionsButton
    }()
    
    let collectionsPathLabel = NSTextField(labelWithString: "Collections Path:")
    let collectionsPathControl: NSPathControl = {
        let collectionsPathControl = NSPathControl()
        collectionsPathControl.translatesAutoresizingMaskIntoConstraints = false
        collectionsPathControl.focusRingType = .none
        collectionsPathControl.pathStyle = .popUp
        return collectionsPathControl
    }()
    
    let changePathButton: NSButton = {
        let changePathButton = NSButton()
        changePathButton.translatesAutoresizingMaskIntoConstraints = false
        changePathButton.bezelStyle = .roundRect
        changePathButton.title = "Change Path"
        return changePathButton
    }()
    
    let resetButton: NSButton = {
        let resetButton = NSButton()
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.bezelStyle = .roundRect
        resetButton.title = "Reset"
        return resetButton
    }()
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 420))
        self.view.wantsLayer = true
        preferredContentSize = NSSize(width: 420, height: 420)
        
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.accessibility.api"), object: nil, queue: nil) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupPermissionsButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupPermissionsButton()
    }
    
    func setupViews() {
        launchLabel.translatesAutoresizingMaskIntoConstraints = false
        popupLabel.translatesAutoresizingMaskIntoConstraints = false
        popupShortcut.translatesAutoresizingMaskIntoConstraints = false
        captureHotkey.translatesAutoresizingMaskIntoConstraints = false
        captureShortcut.translatesAutoresizingMaskIntoConstraints = false
        importHotkey.translatesAutoresizingMaskIntoConstraints = false
        importShortcut.translatesAutoresizingMaskIntoConstraints = false
        borderColorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        borderWidthLabel.translatesAutoresizingMaskIntoConstraints = false
        permissionsLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionsPathLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        container.addSubview(launchLabel)
        container.addSubview(launchAtLoginButton)
        
        container.addSubview(popupLabel)
        container.addSubview(popupShortcut)
        
        container.addSubview(captureHotkey)
        container.addSubview(captureShortcut)
        
        container.addSubview(importHotkey)
        container.addSubview(importShortcut)
        
        container.addSubview(borderColorLabel)
        container.addSubview(colorWell)
        
        container.addSubview(borderWidthLabel)
        container.addSubview(borderWidthSlider)
        container.addSubview(borderWidthValue)
        container.addSubview(minValueLabel)
        container.addSubview(maxValueLabel)
        
        container.addSubview(permissionsLabel)
        container.addSubview(permissionsButton)
        
        container.addSubview(collectionsPathLabel)
        container.addSubview(collectionsPathControl)
        container.addSubview(changePathButton)
        container.addSubview(resetButton)
        
        let offset = view.frame.size.width / 12
        let constraints = [
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.preferencesInsets.left),
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: Styles.preferencesInsets.top),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.preferencesInsets.right),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Styles.preferencesInsets.bottom),
            
            launchLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Styles.preferencesInsets.top * 2),
            launchLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            launchAtLoginButton.centerYAnchor.constraint(equalTo: launchLabel.centerYAnchor),
            launchAtLoginButton.leadingAnchor.constraint(equalTo: launchLabel.trailingAnchor, constant: offset / 2),
            
            popupLabel.topAnchor.constraint(equalTo: launchLabel.bottomAnchor, constant: Styles.preferencesInsets.top * 1.35),
            popupLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            popupShortcut.centerYAnchor.constraint(equalTo: popupLabel.centerYAnchor),
            popupShortcut.leadingAnchor.constraint(equalTo: launchLabel.trailingAnchor, constant: offset / 2),
            
            captureHotkey.topAnchor.constraint(equalTo: popupLabel.bottomAnchor, constant: Styles.preferencesInsets.top * 1.35),
            captureHotkey.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            captureShortcut.centerYAnchor.constraint(equalTo: captureHotkey.centerYAnchor),
            captureShortcut.leadingAnchor.constraint(equalTo: captureHotkey.trailingAnchor, constant: offset / 2),
            
            importHotkey.topAnchor.constraint(equalTo: captureHotkey.bottomAnchor, constant: Styles.preferencesInsets.top * 1.35),
            importHotkey.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            importShortcut.centerYAnchor.constraint(equalTo: importHotkey.centerYAnchor),
            importShortcut.leadingAnchor.constraint(equalTo: importHotkey.trailingAnchor, constant: offset / 2),
            
            borderColorLabel.topAnchor.constraint(equalTo: importHotkey.bottomAnchor, constant: Styles.preferencesInsets.top * 1.35),
            borderColorLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            colorWell.centerYAnchor.constraint(equalTo: borderColorLabel.centerYAnchor),
            colorWell.leadingAnchor.constraint(equalTo: borderColorLabel.trailingAnchor, constant: offset / 2),
            colorWell.widthAnchor.constraint(equalToConstant: 75),
            colorWell.heightAnchor.constraint(equalToConstant: 23),
            
            borderWidthLabel.topAnchor.constraint(equalTo: borderColorLabel.bottomAnchor, constant: Styles.preferencesInsets.top * 1.65),
            borderWidthLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            borderWidthSlider.centerYAnchor.constraint(equalTo: borderWidthLabel.centerYAnchor),
            borderWidthSlider.leadingAnchor.constraint(equalTo: borderWidthLabel.trailingAnchor, constant: offset / 2),
            borderWidthSlider.widthAnchor.constraint(equalToConstant: 125),
            borderWidthValue.centerYAnchor.constraint(equalTo: borderWidthSlider.centerYAnchor),
            borderWidthValue.leadingAnchor.constraint(equalTo: borderWidthSlider.trailingAnchor, constant: Styles.labelInsets.left),
            minValueLabel.leadingAnchor.constraint(equalTo: borderWidthSlider.leadingAnchor),
            minValueLabel.topAnchor.constraint(equalTo: borderWidthSlider.bottomAnchor, constant: Styles.labelInsets.top),
            maxValueLabel.trailingAnchor.constraint(equalTo: borderWidthSlider.trailingAnchor),
            maxValueLabel.topAnchor.constraint(equalTo: minValueLabel.topAnchor),
            
            permissionsLabel.topAnchor.constraint(equalTo: minValueLabel.bottomAnchor, constant: Styles.preferencesInsets.top),
            permissionsLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            permissionsButton.centerYAnchor.constraint(equalTo: permissionsLabel.centerYAnchor),
            permissionsButton.leadingAnchor.constraint(equalTo: permissionsLabel.trailingAnchor, constant: offset / 2),
            
            collectionsPathLabel.topAnchor.constraint(equalTo: permissionsLabel.bottomAnchor, constant: Styles.preferencesInsets.top * 1.35),
            collectionsPathLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            collectionsPathControl.centerYAnchor.constraint(equalTo: collectionsPathLabel.centerYAnchor, constant: -3),
            collectionsPathControl.leadingAnchor.constraint(equalTo: collectionsPathLabel.trailingAnchor, constant: offset / 2 - 5),
            collectionsPathControl.widthAnchor.constraint(equalToConstant: 120),
            
            changePathButton.topAnchor.constraint(equalTo: collectionsPathControl.bottomAnchor, constant: Styles.labelInsets.top),
            changePathButton.leadingAnchor.constraint(equalTo: permissionsButton.leadingAnchor),
            
            resetButton.topAnchor.constraint(equalTo: collectionsPathControl.bottomAnchor, constant: Styles.labelInsets.top),
            resetButton.leadingAnchor.constraint(equalTo: changePathButton.trailingAnchor, constant: Styles.labelInsets.left),
        ]
        NSLayoutConstraint.activate(constraints)
        
        launchAtLoginButton.target = self
        launchAtLoginButton.action = #selector(setLaunchAtLogin)
        launchAtLoginButton.state = GlobalSettings.launchAtLogin ? .on : .off
        
        colorWell.target = self
        colorWell.action = #selector(colorWellItemAction(_:))
        colorWell.color = UserDefaults.standard.color(forKey: "borderColor") ?? NSColor.white
        
        minValueLabel.stringValue = String(borderWidthSlider.minValue)
        maxValueLabel.stringValue = String(borderWidthSlider.maxValue)
        
        borderWidthSlider.target = self
        borderWidthSlider.action = #selector(sliderChanged(_:))
        borderWidthValue.stringValue = String(format: "%.2f", GlobalSettings.borderWidth)
        
        collectionsPathControl.delegate = self
        collectionsPathControl.url = FileManagerController.shared?.collectionsURL
        collectionsPathControl.action = #selector(pathChanged(_:))
        
        popupShortcut.associatedUserDefaultsKey = "popup"
        captureShortcut.associatedUserDefaultsKey = "capture"
        importShortcut.associatedUserDefaultsKey = "import"
    }
    
    private func readPrivileges(prompt: Bool) -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt]
        let status = AXIsProcessTrustedWithOptions(options)
        print("Reading Accessibility privileges - Current access status:", String(status))
        return status
    }
    
    @objc func sliderChanged(_ sender: NSSlider) {
        let newWidth = CGFloat(sender.floatValue)
        GlobalSettings.borderWidth = newWidth
        borderWidthValue.stringValue = String(format: "%.2f", newWidth)
    }
    
    @objc func colorWellItemAction(_ sender: NSColorWell) {
        UserDefaults.standard.set(sender.color, forKey: "borderColor")
    }
    
    func setupPermissionsButton() {
        if readPrivileges(prompt: false) {
            permissionsButton.title = "Accessibility Enabled"
            permissionsButton.image = NSImage(named: NSImage.statusAvailableName)
            permissionsButton.imagePosition = .imageLeading
            permissionsButton.isEnabled = false
        } else {
            permissionsButton.title = "Enable Accessibility"
            permissionsButton.image = NSImage(named: NSImage.statusUnavailableName)
            permissionsButton.imagePosition = .imageLeading
            permissionsButton.isEnabled = true
        }
    }
    
    @objc func setLaunchAtLogin() {
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let launchAgentsFolder = libraryDirectory.appendingPathComponent("LaunchAgents")
        let fileName = FileManagerController.shared!.bundleID + ".plist"
        let launchAgentFile = launchAgentsFolder.appendingPathComponent(fileName)
        GlobalSettings.launchAtLogin = (launchAtLoginButton.state == .on) ? true : false
        if GlobalSettings.launchAtLogin {
            let plistDictionary : [String: Any] = [
                "Label": FileManagerController.shared!.bundleID,
                "LimitLoadToSessionType": "Aqua",
                "Program": "/Users/timothypark/Library/Developer/Xcode/DerivedData/Stickers-dwnioeqamrfywlflcpnextozdnuj/Build/Products/Debug/Stickers.app/Contents/MacOS/Stickers",
                "RunAtLoad": true,
            ]
            
            // program arguments for release
            // ["/usr/bin/open", "/Applications/Stickers.app"]
            // "/Applications/Stickers.app/Contents/MacOS/Stickers"
            
            let dict = NSDictionary(dictionary: plistDictionary)
            dict.write(to: launchAgentFile, atomically: true)
        } else {
            do {
                try FileManager.default.removeItem(atPath: launchAgentFile.path)
            } catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
}

extension SettingsViewController: NSPathControlDelegate {
    
    @objc func pathChanged(_: Any?) {
        print(collectionsPathControl.url as Any)
    }
    
    func pathControl(_: NSPathControl, willDisplay openPanel: NSOpenPanel) {
        openPanel.canChooseFiles = false
        openPanel.prompt = "Select"
    }

    func pathControl(_ pathControl: NSPathControl, willPopUp menu: NSMenu) {
        if let window = view.window {
            window.makeFirstResponder(pathControl)
        }
    }
    
}
