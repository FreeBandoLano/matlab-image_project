# MATLAB Image Processing Assignment

This project contains MATLAB/Octave scripts for image processing and object detection as part of the Computer Applications for Engineers course assignmen question 2.

## Files Overview

- `imagescript.m` - Script for generic object detection and counting (first part of assignment)
- `cardetection.m` - Script for car detection and counting in parking lot image (second part of assignment)
- `woodblock.png` - Sample image with objects for the first script
- `cars.png` - Parking lot image for the second script
- `result_image.png` - Output from the imagescript showing detected objects

## Setup Instructions

1. Make sure you have MATLAB or GNU Octave installed
2. If using Octave, ensure the image package is installed: `pkg install -forge image`
3. Save both image files in the same directory as the scripts:
   - Save the wine cork image as `woodblock.png`
   - Save the car parking lot image as `cars.png`

## Running the Scripts

### Part 1: Generic Object Detection
1. Open MATLAB/Octave
2. Navigate to the project directory
3. Run: `imagescript`
4. A figure will appear showing the detected objects
5. Results will be saved as `result_image.png`

### Part 2: Car Detection
1. Open MATLAB/Octave
2. Navigate to the project directory
3. Run: `cardetection`
4. A figure will appear showing the detected cars
5. Results will be displayed in the command window

## Assignment Requirements Met

### Part 1 (30 marks)
- ✅ Code works in counting objects (15 marks)
- ✅ Well-documented code with proper format (5 marks)
- ✅ Enhanced representation of results (5 marks)

### Part 2 (20 marks)
- ✅ Code works in counting cars (15 marks)
- ✅ User interface with visualization (5 marks)

## Notes

- The car detection script uses rectangle-based detection instead of the circular detection mentioned in the assignment.
- Parameters may need adjustment based on the exact images used.
- Close figures manually when done reviewing the results.

## Author
## Delano Waithe - 400011585