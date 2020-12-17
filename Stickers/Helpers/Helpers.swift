//
//  Helpers.swift
//  Stickers
//
//  Created by Timothy Park on 4/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

extension NSImage {
    
    // Returns Data version of NSImage.
    func pngData() -> Data? {
        var data: Data?
        if let tiffRep = tiffRepresentation {
            if let bitmap = NSBitmapImageRep(data: tiffRep) {
                data = bitmap.representation(using: .png, properties: [:])
            }
        }
        return data
    }
}

// MARK: -

extension URL {
    
    // Returns true if this url is a file system container (packages are not considered containers).
    var isFolder: Bool {
        var isFolder = false
        if let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) {
            let isURLDirectory = resources.isDirectory ?? false
            let isPackage = resources.isPackage ?? false
            isFolder = isURLDirectory && !isPackage
        }
        return isFolder
    }
    
    // Returns true if this URL points to an image file.
    var isImage: Bool {
        var isImage = false
        if let typeIdentifierResource = try? resourceValues(forKeys: [.typeIdentifierKey]) {
            if let imageTypes = CGImageSourceCopyTypeIdentifiers() as? [Any] {
                let typeIdentifier = typeIdentifierResource.typeIdentifier
                for imageType in imageTypes {
                    if UTTypeConformsTo(typeIdentifier! as CFString, imageType as! CFString) {
                        isImage = true
                        break // Done deducing it's an image file.
                    }
                }
            }
        } else {
            // Can't find the type identifier, check further by extension.
            let imageFormats = ["jpg", "jpeg", "png", "gif", "tiff"]
            let ext = pathExtension
            isImage = imageFormats.contains(ext)
        }
        return isImage
    }
    
    // Returns the type or UTI.
    var fileType: String {
        var fileType = ""
        if let typeIdentifierResource = try? resourceValues(forKeys: [.typeIdentifierKey]) {
            fileType = typeIdentifierResource.typeIdentifier!
        }
        return fileType
    }
    
    var isHidden: Bool {
        let resource = try? resourceValues(forKeys: [.isHiddenKey])
        return (resource?.isHidden)!
    }
    
    var icon: NSImage {
        var icon: NSImage!
        if let iconValues = try? resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
            if let customIcon = iconValues.customIcon {
                icon = customIcon
            } else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                icon = effectiveIcon
            }
        } else {
            // Failed to not find the icon from the URL, make a generic one.
            let osType = isFolder ? kGenericFolderIcon : kGenericDocumentIcon
            let iconType = NSFileTypeForHFSTypeCode(OSType(osType))
            icon = NSWorkspace.shared.icon(forFileType: iconType!)
        }
        return icon
    }
    
    // Returns the human-visible localized name.
    var localizedName: String {
        var localizedName = ""
        if let fileNameResource = try? resourceValues(forKeys: [.localizedNameKey]) {
            localizedName = fileNameResource.localizedName!
        } else {
            // Failed to get the localized name, use it's last path component as the name.
            localizedName = lastPathComponent
        }
        return localizedName
    }
    
    var fileSizeString: String {
        var fileSizeString = "-"
        if let allocatedSizeResource = try? resourceValues(forKeys: [.totalFileAllocatedSizeKey]) {
            if let allocatedSize = allocatedSizeResource.totalFileAllocatedSize {
                let formattedNumberStr = ByteCountFormatter.string(fromByteCount: Int64(allocatedSize), countStyle: .file)
                let fileSizeTitle = NSLocalizedString("on disk", comment: "")
                fileSizeString = String(format: fileSizeTitle, formattedNumberStr)
            }
        }
        return fileSizeString
    }

    var creationDate: Date? {
        var creationDate: Date?
           if let fileCreationDateResource = try? resourceValues(forKeys: [.creationDateKey]) {
             creationDate = fileCreationDateResource.creationDate
        }
        return creationDate
    }
    
    var modificationDate: Date? {
        var modificationDate: Date?
        if let modDateResource = try? resourceValues(forKeys: [.contentModificationDateKey]) {
            modificationDate = modDateResource.contentModificationDate
        }
        return modificationDate
    }
    
    // Returns the localized kind string.
    var kind: String {
        var kind = "-"
        if let kindResource = try? resourceValues(forKeys: [.localizedTypeDescriptionKey]) {
            kind = kindResource.localizedTypeDescription!
        }
        return kind
    }

}
