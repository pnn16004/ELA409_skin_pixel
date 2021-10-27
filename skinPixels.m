% Color detection in HSV (Hue, Saturation, Value) color space.
% Copyright (c) 2015, Image Analyst
% All rights reserved.
% Modified by Peter Nguyen.
% Original accessible here:
% https://www.mathworks.com/matlabcentral/fileexchange/28512-simplecolordetectionbyhue?s_tid=srchtitle.
function maskedRGBImage = skinPixels(rgbImage, box)

% Convert RGB image to HSV
hsvImage = rgb2hsv(rgbImage);
% Extract out the H, S, and V images individually
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

% Assign the low and high thresholds for each color band.
% Take a guess at the values that might work for the image.
hueThreshLow = 0;
hueThreshHigh = graythresh(hImage); %0.4451 0.3922
%satThreshLow = graythresh(sImage);
satThreshLow = max(min(graythresh(sImage), 0.08), 0.09); %0.1529 0.1490
satThreshHigh = 1.0;
valThreshLow = graythresh(vImage); %0.5451 0.5137
valThreshHigh = 1.0;

% Now apply each color band's particular thresholds to the color band
hueMask = (hImage >= hueThreshLow) & (hImage <= hueThreshHigh);
satMask = (sImage >= satThreshLow) & (sImage <= satThreshHigh);
valMask = (vImage >= valThreshLow) & (vImage <= valThreshHigh);

%%% Mask region of the guessed color
% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the red parts of the image.
coloredObjectsMask = uint8(hueMask & satMask & valMask);

%%% Remove objects smaller than a set number of pixels
% Get rid of small objects using bwareaopen (returns logical).
smallestAcceptableArea = 100; % Keep areas only if they're bigger than this.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));

%%% Border smoothing
% Smooth the border using a morphological closing operation imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);

%%% Regions filled
% Fill in any holes in the regions, since they are most likely red also.
%coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

%Invert image to makee holes into foreground blobs instead,
%call bwareaopen to fill blobs smaller than size, then revert back
coloredObjectsMask = ~bwareaopen(~coloredObjectsMask, 10000);

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
coloredObjectsMask = cast(coloredObjectsMask, 'like', rgbImage);
% 	coloredObjectsMask = cast(coloredObjectsMask, class(rgbImage));

%-
%%%Zero everything in the mask that's not inside the ROI box
coloredObjectsMask(1:end,1:floor(box(1))) = 0; %180
coloredObjectsMask(1:end,ceil(box(1)+box(3)):end) = 0; %500
%-

%%% Masked red, green, blue image
% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* rgbImage(:,:,1);
maskedImageG = coloredObjectsMask .* rgbImage(:,:,2);
maskedImageB = coloredObjectsMask .* rgbImage(:,:,3);

%%%Image after finishing the filtering
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);