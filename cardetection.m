% cardetection.m - detect & count cars in an image

% Make sure the image-processing functions are available
pkg load image;

% 1) Read in the colour image
I = imread('cars.png');  % Assuming the second image is named 'cars.png'

% 2) Convert to grayscale
Igray = rgb2gray(I);

% 3) Binarize via Otsu's method
level = graythresh(Igray);
bw = im2bw(Igray, level);

% 4) Invert if needed (depends on image - cars are generally darker than background)
if mean(bw(:)) > 0.5   % If more white than black, invert
    bw = ~bw;
end

% 5) Remove small noise
bw = bwareaopen(bw, 50);  % Increase minimum size for cars

% 6) Define structuring element for cars (rectangular shape)
se = strel('rectangle', [5, 10]);  % Adjust size based on car appearance

% 7) Morphological operations to enhance car shapes
bw = imclose(bw, se);  % Close gaps within cars
bw = imopen(bw, se);   % Remove non-car shaped objects

% 8) Label connected components
cc = bwconncomp(bw);
numCars = cc.NumObjects;

% 9) Get properties of detected regions
stats = regionprops(cc, 'BoundingBox', 'Area', 'Extent');

% 10) Filter regions based on size and shape to avoid false positives
minArea = 100;      % Minimum car area
maxArea = 5000;     % Maximum car area
minExtent = 0.6;    % Minimum ratio of area to bounding box area (for rectangular shapes)

validCars = 0;
validBoxes = [];

for i = 1:length(stats)
    area = stats(i).Area;
    extent = stats(i).Extent;
    
    if area >= minArea && area <= maxArea && extent >= minExtent
        validCars = validCars + 1;
        validBoxes = [validBoxes; stats(i).BoundingBox];
    end
end

% 11) Create a user interface figure
figure('Name', 'Car Detection', 'NumberTitle', 'off');

% 12) Display original image and overlay boxes
subplot(2,1,1);
imshow(I);
title('Original Image');

subplot(2,1,2);
imshow(I);
hold on;
for k = 1:size(validBoxes, 1)
    bb = validBoxes(k,:);
    rectangle('Position', bb, ...
              'EdgeColor', 'r', ...
              'LineWidth', 2);
end
hold off;   

% 13) Show count in title
title(sprintf('%d cars detected', validCars));

% Add a text annotation explaining the results
annotation('textbox', [0.1, 0.01, 0.8, 0.05], ...
           'String', sprintf('Total detected objects: %d, Filtered car count: %d', numCars, validCars), ...
           'EdgeColor', 'none', ...
           'HorizontalAlignment', 'center');

% 14) Print results to command window
fprintf('Total objects detected: %d\n', numCars);
fprintf('Cars identified after filtering: %d\n', validCars); 