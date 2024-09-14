# Image-Watermarking-Using-Wavelet-Transform

# Image Watermarking Using Wavelet Transform

This MATLAB script demonstrates a watermarking technique using wavelet transforms. The watermark is embedded into a cover image, and various parameters are tested to evaluate the quality of the watermarked image and the extracted watermark. The script also includes functionality to test the robustness of the watermarking against various types of image attacks.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Description](#script-description)
- [Functions](#functions)
- [Example Outputs](#example-outputs)
- [License](#license)

## Prerequisites

- MATLAB with Image Processing Toolbox
- The cover image (`lena.png`)
- The watermark image (`copyright.png`)

## Usage

1. Ensure that `lena.png` and `copyright.png` are in the same directory as the script.
2. Run the script in MATLAB. It will automatically load the images, apply the watermarking algorithm, and display/save the results.

## Script Description

1. **Load Images**: The script reads the cover image and watermark image. It converts them to double precision and processes them to match the required format.
2. **Preprocessing**: The watermark is resized to match the cover image, and both images are padded to ensure their dimensions are multiples of \(2^3\).
3. **Wavelet Transform**: The cover image and watermark undergo a 3-level Discrete Wavelet Transform (DWT).
4. **Embedding Watermark**: The watermark is embedded into the cover image at the third level of the wavelet transform using various values for parameters `k` and `q`.
5. **Reconstruction**: The watermarked image is reconstructed and compared with the original cover image to calculate Mean Squared Error (MSE) and Peak Signal-to-Noise Ratio (PSNR).
6. **Watermark Extraction**: The watermark is extracted from the watermarked image and compared to the original watermark to calculate MSE and PSNR.
7. **Image Attacks**: Various attacks (mean, median, noise, shear) are applied to the cover image, and the watermark is extracted from these attacked images. The quality of the extracted watermark is evaluated.

## Functions

- `meanAttack(image)`: Applies a mean filter to simulate average attack.
- `medianAttack(image)`: Applies a median filter to simulate median attack.
- `noiseAttack(image)`: Adds Gaussian noise to simulate noise attack.
- `shearAttack(image)`: Applies a shear transformation to simulate shear attack.

## Example Outputs

The script generates several figures:
- Watermarked images with different parameter settings.
- Extracted watermarks for each parameter setting.
- Images subjected to various attacks and their corresponding extracted watermarks.

The results are saved as PNG files in the same directory as the script.

## License

This code is provided as-is for educational and research purposes. You are free to use, modify, and distribute this code under the terms of your own licensing agreement.
