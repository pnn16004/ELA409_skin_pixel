%%% detectAndTrackFaces %%%
clc
clear

%%% Instantiate video device, face detector, and KLT object tracker%
vidObj = webcam;
faceDetector = vision.CascadeObjectDetector(); % Finds faces by default
tracker = MultiObjectTrackerKLT;

%%% Get a frame for frame-size information %%%
frame = snapshot(vidObj);
frameSize = size(frame);
Tx = size(frame,2)/2; % text position

%%% Create a video player instance %%%
videoPlayer  = vision.VideoPlayer('Position',[200 100 fliplr(frameSize(1:2)+30)]);

%%% Iterate until we have successfully detected a face %%%
bboxes = [];
while isempty(bboxes)
    framergb = snapshot(vidObj);
    frame = rgb2gray(framergb);
    bboxes = faceDetector.step(frame);
end
tracker.addDetections(frame, bboxes);

%%% And loop until the player is closed %%%
frameNumber = 0;
frameNumberMod = 0;
keepRunning = true;
disp('Press Ctrl-C to exit...');
HRR = 0;
HRL = 0;
LabAvg = zeros(3,1);
RGBAvg = zeros(3,1);
while keepRunning
    
    framergb = snapshot(vidObj);
    frame = rgb2gray(framergb);
    
    if mod(frameNumber, 10) == 0
        % bboxes = faceDetector.step(frame);
        bboxes = 2 * faceDetector.step(imresize(frame, 0.5));
        if ~isempty(bboxes)
            tracker.addDetections(frame, bboxes);
        end
    else
        % Track faces
        tracker.track(frame);
    end
    
    % Display bounding boxes and tracked points.
    displayFrame = insertObjectAnnotation(framergb, 'rectangle',...
        tracker.ROIBboxes, tracker.BoxIds);
    %displayFrame = insertMarker(displayFrame, tracker.Points);
    %videoPlayer.step(displayFrame);
    
    frameNumber = frameNumber + 1;
    frameNumberMod = mod(frameNumberMod, 300); %Only the 300 latest frames
    frameNumberMod = frameNumberMod + 1;
    
    %----------
    %Get the average of each channel
    for i=1:size(tracker.Bboxes,1)
        %Get the ROI of the image using the calculated ROI box
        %RGBImg = imcrop(framergb,tracker.ROIBboxes);
        box = tracker.ROIBboxes(i,:);
        RGBImg = framergb(box(2):box(2)+box(4), box(1):box(1)+box(3), :);
        
        LabImg = rgb2lab(RGBImg);% transformation into Lab color space
        for ch = 1:3
            RGBCh = RGBImg(:,:,ch);
            RGBAvg(ch, frameNumberMod) = mean(RGBCh(:));
            
            LabCh = LabImg(:,:,ch);
            LabAvg(ch, frameNumberMod) = mean(LabCh(:));
        end 
    end
    
    % Start when 120/frameRate sec has passed and divisble by 6c
    if ((frameNumber >= 300) && mod(frameNumber,6) == 0)        
        rgb = RGBAvg;
        %rgb = RGBAvg(2:3,:);
        %rgb = RGBAvg(2,:);

        lab = LabAvg;
        %lab = LabAvg(2:3,:);
        
        HRR = FFT_HR(rgb,size(rgb, 2));
        HRL = FFT_HR(lab,size(lab, 2));
    end
    
    for i=1:size(tracker.Bboxes,1)
        displayFrame = insertText(displayFrame, [Tx-150 10*5*i], 'HRR =', 'FontSize', 20, 'BoxColor', 'red', 'BoxOpacity', 0.9);
        displayFrame = insertText(displayFrame, [Tx-80 10*5*i], num2str(HRR,'%0.2f'), 'FontSize', 20, 'BoxColor', 'red', 'BoxOpacity', 0.9);
        displayFrame = insertText(displayFrame, [Tx+80 10*5*i], 'HRL =', 'FontSize', 20, 'BoxColor', 'blue', 'BoxOpacity', 0.9);
        displayFrame = insertText(displayFrame, [Tx+150 10*5*i], num2str(HRL,'%0.2f'), 'FontSize', 20, 'BoxColor', 'blue', 'BoxOpacity', 0.9);
    end

    videoPlayer.step(displayFrame);
    %----------
end
%%% Clean up %%%
release(videoPlayer);