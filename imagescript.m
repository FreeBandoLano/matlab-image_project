% imagescript.m – detect & count objects in an image
% This script processes an image to identify and count distinct objects.
% It uses image processing techniques including grayscale conversion,
% binarization, noise reduction, and connected component analysis.
% 
% Author: [Your Name]
% Date: [Current Date]
% Course: Computer Applications for Engineers

% Make sure the image-processing functions are available
pkg load image;

% 1) Read in the colour image
fprintf('Loading image...\n');
I = imread('woodblock.png');

% 2) Convert to grayscale
fprintf('Converting to grayscale...\n');
Igray = rgb2gray(I);

% 3) Binarize via Otsu's method
fprintf('Binarizing image...\n');
level = graythresh(Igray);
% Use im2bw instead of imbinarize for Octave compatibility
bw = im2bw(Igray, level);

% 4) Invert if background is white (so objects are 1s)
bw = ~bw;

% 5) Remove small specks (noise)
fprintf('Removing noise...\n');
bw = bwareaopen(bw, 30); % drops any blobs with less than 30 pixels

% 6) Label connected components
fprintf('Finding objects...\n');
cc = bwconncomp(bw);
numObjects = cc.NumObjects;

% 7) Get object properties
stats = regionprops(cc, 'BoundingBox', 'Area', 'Centroid');

% 8) Create a user interface figure
figure('Name', 'Object Detection', 'NumberTitle', 'off');

% 9) Display original and processed images side by side
subplot(2,2,1);
imshow(I);
title('Original Image');

subplot(2,2,2);
imshow(bw);
title('Processed Binary Image');

subplot(2,2,[3,4]);
imshow(I);
hold on;
% Use different colors based on object sizes
for k = 1:numel(stats)
    bb = stats(k).BoundingBox;
    centroid = stats(k).Centroid;
    area = stats(k).Area;
    
    % Choose color based on object size
    if area < 100
        edgeColor = 'g'; % Green for small objects
    elseif area < 500
        edgeColor = 'y'; % Yellow for medium objects
    else
        edgeColor = 'r'; % Red for large objects
    end
    
    % Draw bounding box
    rectangle('Position', bb, ...
              'EdgeColor', edgeColor, ...
              'LineWidth', 2);
          
    % Label object number
    text(centroid(1), centroid(2), num2str(k), ...
         'Color', 'w', 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center');
end
hold off;

% 10) Show count in title with detailed information
title(sprintf('%d objects detected', numObjects));

% 11) Add information text box
infoText = sprintf(['Object Detection Results:\n', ...
                   '- Total objects: %d\n', ...
                   '- Small objects (area < 100): %d\n', ...
                   '- Medium objects (100-500): %d\n', ...
                   '- Large objects (area > 500): %d'], ...
                   numObjects, ...
                   sum([stats.Area] < 100), ...
                   sum([stats.Area] >= 100 & [stats.Area] < 500), ...
                   sum([stats.Area] >= 500));
               
annotation('textbox', [0.1, 0.01, 0.8, 0.08], ...
           'String', infoText, ...
           'EdgeColor', 'none', ...
           'FontSize', 9, ...
           'HorizontalAlignment', 'center');

% 12) Save the result image
fprintf('Saving result image...\n');
saveas(gcf, 'result_image.png');

% 13) Print results to command window
fprintf('Detection complete!\n');
fprintf('Total objects detected: %d\n', numObjects);
fprintf('Results saved to result_image.png\n');

% Keep figure open until user closes it
fprintf('Close the figure window to exit.\n');
