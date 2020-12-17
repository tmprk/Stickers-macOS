//
//  Properties.swift
//  Stickers
//
//  Created by Timothy Park on 8/3/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

enum GlobalSettings {
    @Property(key: "launchAtLogin", defaultValue: false)
    static var launchAtLogin: Bool
    @Property(key: "drawMode", defaultValue: DrawMode.freehand.rawValue)
    static var drawMode: Int
    @Property(key: "borderWidth", defaultValue: 10.0)
    static var borderWidth: CGFloat
    @Property(key: "firstRun", defaultValue: true)
    static var firstRun: Bool
    @Property(key: "selectedCollection", defaultValue: "")
    static var selectedCollection: String
}

@propertyWrapper
struct Property<T> {
    
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
}

extension UserDefaults {
    
    func set(_ color: NSColor, forKey: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            self.set(data, forKey: forKey)
        }
    }
    
    func color(forKey: String) -> NSColor? {
        guard
            let storedData = self.data(forKey: forKey),
            let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: storedData),
            let color = unarchivedData as NSColor?
        else {
            return nil
        }
        return color
    }
    
}
