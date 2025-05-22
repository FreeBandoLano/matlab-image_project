# MATLAB/Octave Project: Projectile Motion & Image Analysis

## Project Overview

This project encompasses two main components developed in MATLAB/Octave:

1.  **Projectile Motion Simulator:** A graphical user interface (GUI) application that calculates and visualizes projectile trajectories under various physical conditions. It allows users to set parameters like initial velocity, launch angle, height, and to factor in air drag or simulate bounces.
2.  **Image-Based Object Detection:** A set of scripts for analyzing images to detect and count objects. This includes a generic object counter and a specialized script for detecting cars in a parking lot scene.

These tools are designed for educational and demonstrative purposes in engineering applications.

## Files Overview

-   `project_motion_solver.m`: Launches the GUI for the Projectile Motion Simulator.
-   `solveprojectile.m`: The core calculation engine called by `project_motion_solver.m`. It handles the physics for different scenarios (general launch, target clearance, horizontal launch with/without bounce, double projectile).
-   `imagescript.m`: Script for generic object detection and counting (e.g., in `woodblock.png`).
-   `cardetection.m`: Script for specific car detection and counting (e.g., in `cars.png`).
-   `woodblock.png`: Sample image with various objects for `imagescript.m`.
-   `cars.png`: Parking lot image for `cardetection.m`.
-   `result_image.png`: Example output from `imagescript.m` showing detected objects.
-   `.gitignore`: Specifies intentionally untracked files that Git should ignore.
-   `README.md`: This file.

## Setup Instructions

1.  Ensure you have MATLAB or GNU Octave installed.
2.  If using Octave, ensure the `image` package (for image processing scripts) is installed:
    ```octave
    pkg load image
    pkg install -forge image % Run this once if not already installed
    ```
3.  Save all script files (`.m`) and image files (`.png`) in the same directory.
    -   Default image for generic object detection: `woodblock.png`
    -   Default image for car detection: `cars.png`

## Running the Scripts

### Projectile Motion Simulator
1.  Open MATLAB/Octave.
2.  Navigate to the project directory.
3.  Run the solver GUI:
    ```matlab
    project_motion_solver
    ```
4.  Input desired parameters in the GUI (initial velocity, angle, height, etc.).
5.  Select a scenario (e.g., General Launch, Horizontal Launch with Bounce).
6.  Optionally, enable Air Drag or specify Target X/Y coordinates.
7.  Click "Solve".
8.  Results (time of flight, max height, range, target status) will be displayed in the GUI, and a plot of the trajectory will be generated. For "Horizontal Launch with Bounce", ensure to provide a bounce efficiency (0-1). For "Horizontal Launch" scenarios, the launch angle is automatically set to 0.

### Part 1: Generic Object Detection (`imagescript.m`)
1.  Open MATLAB/Octave.
2.  Navigate to the project directory.
3.  Ensure `woodblock.png` is present or modify the script to load a different image.
4.  Run:
    ```matlab
    imagescript
    ```
5.  A figure will appear showing the original image, the processed binary image, and the original image with detected objects highlighted by bounding boxes and numbered.
6.  Object counts (total, small, medium, large) will be displayed in an annotation on the figure and printed to the command window.
7.  The resulting image with detections will be saved as `result_image.png`.

### Part 2: Car Detection (`cardetection.m`)
1.  Open MATLAB/Octave.
2.  Navigate to the project directory.
3.  Ensure `cars.png` is present or modify the script to load a different image.
4.  Run:
    ```matlab
    cardetection
    ```
5.  A figure will appear showing the original image and another subplot with detected cars highlighted by bounding boxes.
6.  The total number of initially detected objects and the final count of filtered cars will be displayed in an annotation on the figure and printed to the command window.

## Assignment Requirements Met (Course Specific)

### Part 1 (Image Script - 30 marks)
-   ✅ Code works in counting objects (15 marks)
-   ✅ Well-documented code with proper format (5 marks)
-   ✅ Enhanced representation of results (5 marks)

### Part 2 (Car Detection Script - 20 marks)
-   ✅ Code works in counting cars (15 marks)
-   ✅ User interface with visualization (5 marks)

*(This section pertains to specific course grading criteria and may not be relevant for general users.)*

## Notes

-   The image detection scripts (`imagescript.m`, `cardetection.m`) rely on the Octave `image` package or MATLAB's Image Processing Toolbox.
-   Parameters within the detection scripts (e.g., `bwareaopen` thresholds, structuring element sizes, area/extent filters for cars) may need adjustment for optimal performance on different images.
-   Close figure windows manually after reviewing results.
-   The projectile motion solver provides various scenarios; some, like "Horizontal Launch," will override the angle input.

## Author
Delano Waithe - 400011585
