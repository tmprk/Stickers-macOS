//
//  AboutViewController.swift
//  Stickers
//
//  Created by Timothy Park on 7/16/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa
import SwiftyMarkdown

class AboutViewController: NSViewController {
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 350))
        self.view.wantsLayer = true
        preferredContentSize = NSSize(width: 300, height: 350)
        
        setupViews()
        // attributionsView.stringValue = "Open source libraries frameworks: MASShortcut, Cocoapods"
    }
    
    let applicationIcon: NSImageView = {
        let applicationIcon = NSImageView()
        applicationIcon.translatesAutoresizingMaskIntoConstraints = false
        applicationIcon.image = NSImage(named: NSImage.applicationIconName)
        return applicationIcon
    }()
    
    let appTitleLabel: NSTextField = {
        let appTitleLabel = NSTextField(labelWithString: "Stickers")
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        appTitleLabel.font = NSFont.systemFont(ofSize: 38, weight: .medium)
        return appTitleLabel
    }()
    
    let versionLabel: NSTextField = {
        let versionLabel = NSTextField(labelWithString: "Version 1.0.0 (1)")
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = .tertiaryLabelColor
        return versionLabel
    }()
    
    let attributionsView: NSTextField = {
        let markdownFileUrl = Bundle.main.url(forResource: "attributions", withExtension: "md")!
        let md = SwiftyMarkdown(url: markdownFileUrl)!
        md.h1.fontSize = 16
        md.underlineLinks = false
        let textView = MarkdownTextfield(md.attributedString())
        textView.allowsEditingTextAttributes = true
        textView.isSelectable = true
        return textView
    }()
    
    let restorePurchasesButton: NSButton = {
        let restorePurchasesButton = NSButton()
        restorePurchasesButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchasesButton.bezelStyle = .texturedRounded
        restorePurchasesButton.title = "Restore Purchases"
        restorePurchasesButton.isEnabled = false
        return restorePurchasesButton
    }()
    
    let supportButton: NSButton = {
        let supportButton = NSButton()
        supportButton.translatesAutoresizingMaskIntoConstraints = false
        supportButton.bezelStyle = .texturedRounded
        supportButton.title = "Support"
        return supportButton
    }()
    
    func setupViews() {
        view.addSubview(applicationIcon)
        view.addSubview(appTitleLabel)
        view.addSubview(versionLabel)
        view.addSubview(attributionsView)
        view.addSubview(restorePurchasesButton)
        view.addSubview(supportButton)
        
        let constraints = [
            applicationIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.preferencesInsets.left * 1.8),
            applicationIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: Styles.preferencesInsets.top * 1.2),
            applicationIcon.widthAnchor.constraint(equalToConstant: view.frame.width / 4),
            applicationIcon.heightAnchor.constraint(equalToConstant: view.frame.width / 4),
            
            appTitleLabel.centerYAnchor.constraint(equalTo: applicationIcon.centerYAnchor, constant: -Styles.preferencesInsets.top * 0.5),
            appTitleLabel.leadingAnchor.constraint(equalTo: applicationIcon.trailingAnchor, constant: Styles.preferencesInsets.left * 1.4),
            
            versionLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor),
            versionLabel.leadingAnchor.constraint(equalTo: appTitleLabel.leadingAnchor),
            
            attributionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.preferencesInsets.left),
            attributionsView.topAnchor.constraint(equalTo: applicationIcon.bottomAnchor, constant: Styles.preferencesInsets.top * 1.2),
            attributionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.preferencesInsets.right),
            
            restorePurchasesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.preferencesInsets.left * 1.8),
            restorePurchasesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Styles.preferencesInsets.bottom * 1.2),
            
            supportButton.leadingAnchor.constraint(equalTo: restorePurchasesButton.trailingAnchor, constant: Styles.preferencesInsets.left),
            supportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.preferencesInsets.right * 1.8),
            supportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Styles.preferencesInsets.bottom * 1.2)
        ]
        NSLayoutConstraint.activate(constraints)
        
        supportButton.target = self
        supportButton.action = #selector(sendEmail)
    }
    
    @objc func sendEmail() {
        let emailBody = "I have some feedback and/or suggestions: "
        let emailService = NSSharingService.init(named: NSSharingService.Name.composeEmail)!
        emailService.recipients = ["cachedseed@gmail.com"]
        emailService.subject = "Stickers App Support"
        if emailService.canPerform(withItems: [emailBody]) {
            emailService.perform(withItems: [emailBody])
        } else {
            print("email client not set up")
        }
    }
    
}
