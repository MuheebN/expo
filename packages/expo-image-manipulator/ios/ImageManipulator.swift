// Copyright 2024-present 650 Industries. All rights reserved.

import ExpoModulesCore

public final class ImageManipulator: SharedObject {
  private var currentTask: Task<UIImage, Error>

  init(appContext: AppContext, url: URL) {
    currentTask = Task(priority: .background) {
      return try await loadImage(atUrl: url, appContext: appContext)
    }
    super.init()
    applyOrientationFix()
  }

  init(originalImage image: UIImage) {
    currentTask = Task(priority: .background) {
      return image
    }
    super.init()
    applyOrientationFix()
  }

  internal func addTransformer(_ transformer: ImageTransformer) {
    currentTask = Task(priority: .background) { [currentTask] in
      let image = try await currentTask.value
      return try await transformer.transform(image: image)
    }
  }

  internal func applyOrientationFix() {
    // Immediately try to fix the orientation once the image is loaded
    addTransformer(ImageFixOrientationTransformer())
  }

  internal func generate() async throws -> UIImage {
    return try await currentTask.value
  }
}
