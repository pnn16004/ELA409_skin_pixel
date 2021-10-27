% Select video from file browser
[file,path] = uigetfile({'*.*',  'All Files (*.*)'}, 'Select a video',...
    'ASP_P/crop-trim-04_22.mp4');
inputFilePath = fullfile(path,file);
%inputFilePath = 'ASP_P/crop-trim-04_22.mp4';

% Set path to video to be processed
videoFileReader = vision.VideoFileReader(inputFilePath);

% Get a frame for frame-size information
frame = step(videoFileReader);
frameSize = size(frame);
Tx = frameSize(2); % text position

% screen = get(0,'screensize');
% width = screen(3);
% height = screen(4);
% screenSize = [width height] * 0.75;
% screenPos = [(width-screenSize(1))/2 (height-screenSize(2))/2];
% screen = [screenPos screenSize];
% videoPlayer  = vision.VideoPlayer('Position',screen,'Name','Video');
videoPlayer = vision.DeployableVideoPlayer('Name','Heart Rate Extraction - Filtered vs Target');

boxSize = [frameSize(2)*0.55 frameSize(1)*1];
boxPos = [(frameSize(2)-boxSize(1))/2 (frameSize(1)-boxSize(2))/2];
box = [boxPos boxSize];

frameNumber = 0;
frameTotal = 120;

RGBAvg = zeros(3,frameTotal);
LABAvg = zeros(3,frameTotal);
YCbCrAvg = zeros(3,frameTotal);

while ~isDone(videoFileReader)
    frame = step(videoFileReader);
    
    RGBImg = skinPixels(frame, box);
    %RGBImg = imcrop(frame,box);
    
    frame = insertShape(frame, 'Rectangle', box);
    frame = imfuse(RGBImg,frame,'montage');
    
    frameNumber = frameNumber + 1;
    
    [RGBAvg,LABAvg,YCbCrAvg] = colorSpaces(frameNumber, frameTotal,...
        RGBImg, RGBAvg, LABAvg, YCbCrAvg);
    
    if frameNumber > frameTotal
        HRR = FFT_HR(RGBAvg,size(RGBAvg, 2));
        HRL = FFT_HR(LABAvg,size(LABAvg, 2));
        HRY = FFT_HR(YCbCrAvg,size(YCbCrAvg, 2));
        
        frame = insertText(frame, [Tx-250 10*2], 'HRR =', 'FontSize', 20, 'BoxColor', 'red', 'BoxOpacity', 0.9);
        frame = insertText(frame, [Tx-180 10*2], num2str(HRR,'%0.2f'), 'FontSize', 20, 'BoxColor', 'red', 'BoxOpacity', 0.9);
        frame = insertText(frame, [Tx-70 10*2], 'HRL =', 'FontSize', 20, 'BoxColor', 'blue', 'BoxOpacity', 0.9);
        frame = insertText(frame, [Tx+0 10*2], num2str(HRL,'%0.2f'), 'FontSize', 20, 'BoxColor', 'blue', 'BoxOpacity', 0.9);
        frame = insertText(frame, [Tx+100 10*2], 'HRY =', 'FontSize', 20, 'BoxColor', 'green', 'BoxOpacity', 0.9);
        frame = insertText(frame, [Tx+170 10*2], num2str(HRY,'%0.2f'), 'FontSize', 20, 'BoxColor', 'green', 'BoxOpacity', 0.9);
    end
    
    videoPlayer.step(frame);
end

release(videoFileReader);
release(videoPlayer);
delete(videoPlayer);