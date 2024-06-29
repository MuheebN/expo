// Copyright 2021-present 650 Industries. All rights reserved.

import CoreGraphics
import Photos
import UIKit
import ExpoModulesCore
import SDWebImageWebPCoder

public class ImageManipulatorModule: Module {
  typealias LoadImageCallback = (Result<UIImage, Error>) -> Void

  public func definition() -> ModuleDefinition {
    Name("ExpoImageManipulator")

    // Legacy API, first deprecated in SDK 52
    AsyncFunction("manipulateAsync") { (url: URL, actions: [ManipulateAction], options: ManipulateOptions) in
      guard let appContext else {
        throw Exceptions.AppContextLost()
      }
      let manipulator = ImageManipulator(appContext: appContext, url: url)

      for action in actions {
        if let resize = action.resize {
          manipulator.addTransformer(ImageResizeTransformer(options: resize))
        } else if let rotate = action.rotate {
          manipulator.addTransformer(ImageRotateTransformer(rotate: rotate))
        } else if let flip = action.flip {
          manipulator.addTransformer(ImageFlipTransformer(flip: flip))
        } else if let crop = action.crop {
          manipulator.addTransformer(ImageCropTransformer(options: crop))
        }
      }

      let newImage = try await manipulator.generate()
      let saveResult = try saveImage(newImage, options: options, appContext: appContext)

      return [
        "uri": saveResult.url.absoluteString,
        "width": newImage.cgImage?.width ?? 0,
        "height": newImage.cgImage?.height ?? 0,
        "base64": options.base64 ? saveResult.data.base64EncodedString() : nil
      ]
    }

    Function("load") { (url: URL) in
      return ImageManipulator(appContext: appContext!, url: url)
    }

    Function("manipulate") { (image: ImageRef) in
      return ImageManipulator(originalImage: image.pointer)
    }

    Class(ImageManipulator.self) {
      Function("resize") { (manipulator, options: ResizeOptions) in
        manipulator.addTransformer(ImageResizeTransformer(options: options))
        return manipulator
      }

      Function("rotate") { (manipulator, rotate: Double) in
        manipulator.addTransformer(ImageRotateTransformer(rotate: rotate))
        return manipulator
      }

      Function("flip") { (manipulator, flipType: FlipType) in
        manipulator.addTransformer(ImageFlipTransformer(flip: flipType))
        return manipulator
      }

      Function("crop") { (manipulator, rect: CropRect) in
        manipulator.addTransformer(ImageCropTransformer(options: rect))
        return manipulator
      }

      AsyncFunction("generateAsync") { (manipulator) -> ImageRef in
        let image = try await manipulator.generate()
        return ImageRef(image)
      }
    }

    Class("Image", ImageRef.self) {
      Property("width") { (image: ImageRef) -> Int in
        return image.pointer.cgImage?.width ?? 0
      }

      Property("height") { (image: ImageRef) -> Int in
        return image.pointer.cgImage?.height ?? 0
      }

      AsyncFunction("saveAsync") { (image: ImageRef, options: ManipulateOptions) in
        guard let appContext else {
          throw Exceptions.AppContextLost()
        }
        let result = try saveImage(image.pointer, options: options, appContext: appContext)

        // We're returning a dict instead of a path directly because in the future we'll replace it
        // with a shared ref to the file once this feature gets implemented in expo-file-system.
        // This should be fully backwards-compatible switch.
        return [
          "path": result.url.absoluteString,
          "uri": result.url.absoluteString,
          "width": image.pointer.cgImage?.width ?? 0,
          "height": image.pointer.cgImage?.height ?? 0,
          "base64": options.base64 ? result.data.base64EncodedString() : nil
        ]
      }
    }
  }
}
