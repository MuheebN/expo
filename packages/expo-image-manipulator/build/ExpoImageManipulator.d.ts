import { Action, Manipulator, ImageRef, SaveOptions } from './ImageManipulator.types';
type ImageManipulatorModule = {
    Manipulator: typeof Manipulator;
    load(url: string): Manipulator;
    manipulate(image: ImageRef): Manipulator;
    manipulateAsync(uri: string, actions: Action[], saveOptions: SaveOptions): any;
};
declare const _default: ImageManipulatorModule;
export default _default;
//# sourceMappingURL=ExpoImageManipulator.d.ts.map