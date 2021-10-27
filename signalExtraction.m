function avg = signalExtraction(frameNumber, frameTotal, img, avg)

[~,~,ch] = size(img);

%For each channel, line up pixels as 1D array, then get mean
chMean = mean(reshape(img,[],ch))';
if frameNumber <= frameTotal
    %Save to corresponding frame
    avg(:, frameNumber) = chMean;
else
    %FIFO, push whole array so it's in order
    avg = [avg(:,2:frameTotal) chMean];
end