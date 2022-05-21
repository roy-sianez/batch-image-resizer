//
//  main.swift
//  Resizer
//
//  Created by Roy Sianez on 5/18/22.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

typealias Size = (width: Int?, height: Int?)


// MARK: Parameters

let imageAbsoluteFilePaths: [String] = [
    // Add absolute file paths for images.
    "/Users/roysianez/Desktop/App Icon P3.png"
]

let imageSizes: [Size] = [
    // Add sizes. Each image will be resized to all of the included sizes.
    // If the width or height is nil, the missing dimension will be inferred to
    // preserve the aspect ratio of the image.
    (32, 32),
    (64, 64),
]

func newFileName(from originalFileName: String, with size: Size) -> String {
    // use this function to customize the names of the output files
    let (width, height) = size
    let widthDescriptor = width == nil ? "" : "-\(width!)w"
    let heightDescriptor = height == nil ? "" : "-\(height!)h"
    if (widthDescriptor == "" && heightDescriptor == "") {
        return originalFileName + "-original"
    } else {
        return originalFileName + widthDescriptor + heightDescriptor
    }
}


// MARK: Script

let images: [(imageSource: CGImageSource, originalFile: URL)] =
    imageAbsoluteFilePaths.compactMap { filePath in
        let url = URL(fileURLWithPath: filePath)
        guard let image = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Cannot load image with URL: \(url.absoluteString)")
            return nil
        }
        return (imageSource: image, originalFile: url)
    }

for image in images {
    for size in imageSizes {
        let (imageSource, originalFile) = image
        let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)!
        
        let finalSize = sizeUsingAspectRatio(
            specifiedSize: size,
            originalImageSize: (cgImage.width, cgImage.height))
        let fileName = newFileName(
            from: originalFile.deletingPathExtension().lastPathComponent,
            with: finalSize)
        let outputFile = originalFile
            .deletingLastPathComponent()
            .appendingPathComponent("\(fileName).\(originalFile.pathExtension)")
        
        let context = CGContext(
            data: nil,
            width: finalSize.width,
            height: finalSize.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: cgImage.bitmapInfo.rawValue)!
        context.interpolationQuality = .high
        context.draw(
            cgImage,
            in: .init(
                x: 0, y: 0,
                width: finalSize.width, height: finalSize.height))
        
        let resizedImage = context.makeImage()!
        
        let destination = CGImageDestinationCreateWithURL(
            outputFile as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, resizedImage, nil)
        if !CGImageDestinationFinalize(destination) {
            print("Could not save image: \(outputFile.absoluteString)")
        }
    }
}


// MARK: Helper Functions

func sizeUsingAspectRatio(
    specifiedSize: Size,
    originalImageSize: (width: Int, height: Int)
) -> (width: Int, height: Int) {
    if (specifiedSize.width == nil && specifiedSize.height == nil) {
        return originalImageSize
    }
    if let width = specifiedSize.width, let height = specifiedSize.height {
        return (width: width, height: height)
    }
    if let width = specifiedSize.width {
        return (
            width: width,
            height: originalImageSize.height
                        * (width / originalImageSize.width))
    }
    if let height = specifiedSize.height {
        return (
            width: originalImageSize.width
                       * (height / originalImageSize.height),
            height: height)
    }
    fatalError("This point will never be reached")
}


// MARK: Info

// See the following websites for information about manipulating images
// in macOS:

// https://nshipster.com/image-resizing/
// https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
