# MATLAB Image Object Counter - ENGR0240 Project

This project is part of the coursework for ENGR0240  Computer Applications for Engineers at UWI. It involves developing a MATLAB application with a Graphical User Interface (GUI) to detect, count, and highlight objects within images.

## Project Goal

*   Apply MATLAB programming skills to solve a practical image analysis problem.
*   Implement image processing algorithms (grayscale conversion, thresholding, noise reduction, object detection).
*   Develop an interactive GUI using MATLAB App Designer for loading images and displaying results.
*   Count objects in various test images and visually mark them with bounding boxes.

## Current Status

*   Core image processing script (imagescript.m) developed and tested via command line (Octave/MATLAB).
*   Initial setup for GitHub repository (master branch).
*   Next step: Develop the GUI using MATLAB App Designer (imageCounterApp.mlapp).

## How to Run (Command Line - imagescript.m)

1.  Ensure MATLAB or Octave is installed with the Image Processing Toolbox/package.
    *   Octave (Ubuntu/WSL): sudo apt install octave-image
2.  Navigate to the project directory.
3.  Run the script:
    *   MATLAB: Open imagescript.m and run it.
    *   Octave: octave imagescript.m
4.  The script will process woodblock.png by default, print the object count to the console, and save the output as esult_image.png.

## Dependencies

*   MATLAB (R2020a or later recommended) or Octave (7.x or later)
*   MATLAB Image Processing Toolbox OR octave-image package

## Author

*   Argentum D. Harrison-Montplaisir
*   GitHub: FreeBandoLano
