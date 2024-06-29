import { requireNativeModule } from 'expo-modules-core';

import { Action, Manipulator, ImageRef, SaveOptions } from './ImageManipulator.types';

type ImageManipulatorModule = {
  Manipulator: typeof Manipulator;

  load(url: string): Manipulator;

  manipulate(image: ImageRef): Manipulator;

  manipulateAsync(uri: string, actions: Action[], saveOptions: SaveOptions);
};

export default requireNativeModule<ImageManipulatorModule>('ExpoImageManipulator');
