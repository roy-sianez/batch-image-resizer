# Batch Image Resizer

A macOS command-line tool to resize images in bulk.

To use the resizer, open the Xcode project. Under the "Parameters" section, add the absolute file paths of the images you want to resize and the sizes you want to use. Then run the script and the resized images will be saved to the same location.

The tool preserves the color profile information from the original image, so it is useful for correctly resizing wide-color images (such as app icons).
