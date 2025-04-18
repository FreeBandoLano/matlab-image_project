% imagescript.m – detect & count objects in an image

% load the image

pkg load image; % make sure the image-processing functions are available

% 1) Read in the colour image
I = imread('woodblock.png');

% 2) Convert to grayscale
Igray = rgb2gray(I);

% 3) Binarize via Otsu's method
level = graythresh(Igray);
% Use im2bw instead of imbinarize for Octave compatibility
bw = im2bw(Igray, level);

% 4) invert if background is white(so objects are 1s)
bw = ~bw;

%5 ) Remove small specks (noise)
bw = bwareaopen(bw, 30); % drops any blobs with less than 30 pixels

%6 ) Label connected components
cc = bwconncomp(bw);
numObjects = cc.NumObjects;

% 7) Get bounding boxes 
stats = regionprops(cc, 'BoundingBox');

% 8) Display original image and overlay boxes
imshow(I);
hold on;
for k = 1:numel(stats)
    bb = stats(k).BoundingBox;
    rectangle('Position', bb, ...
              'EdgeColor', 'g', ...
              'LineWidth', 2);
end
hold off;   

% 9) Show count in title
title(sprintf('%d objects detected', numObjects));

% 10) Pause so you can see the resulting image
pause(5);
