//
//  ImageProcessor.swift
//  IconChanger
//
//  Created by Lee Lucci on 2/8/24.
//

import Foundation
import Cocoa

func resizeImage(image: NSImage, targetSize: NSSize) -> NSImage? {
    let newSize = targetSize
    let newRect = NSRect(origin: .zero, size: newSize)
    
    guard let representation = image.bestRepresentation(for: newRect, context: nil, hints: nil) else {
        return nil
    }
    
    let resizedImage = NSImage(size: newSize, flipped: false) { (_) -> Bool in
        return representation.draw(in: newRect)
    }
    
    return resizedImage
}

func saveImage(image: NSImage, to url: URL, format: NSBitmapImageRep.FileType) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let imageData = bitmapImage.representation(using: format, properties: [:]) else {
        return false
    }
    
    do {
        try imageData.write(to: url)
        return true
    } catch {
        print("Failed to save image: \(error)")
        return false
    }
}

func exportImages(image: NSImage, baseName: String, destinationFolder: URL) {
    let sizes: [(String, NSSize)] = [
        ("@1x", NSSize(width: 128, height: 128)),
        ("@2x", NSSize(width: 256, height: 256))
    ]
    
    for (suffix, size) in sizes {
        if let resizedImage = resizeImage(image: image, targetSize: size) {
            let fileName = "\(baseName)\(suffix).png"
            let fileURL = destinationFolder.appendingPathComponent(fileName)
            _ = saveImage(image: resizedImage, to: fileURL, format: .png)
        }
    }
}

