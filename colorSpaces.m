function [RGBAvg,LABAvg,YCbCrAvg] = colorSpaces(frameNumber, frameTotal,...
        RGBImg, RGBAvg, LABAvg, YCbCrAvg)

RGBAvg = signalExtraction(frameNumber, frameTotal, RGBImg, RGBAvg);

LABImg = rgb2lab(RGBImg);
LABAvg = signalExtraction(frameNumber, frameTotal, LABImg, LABAvg);

YCbCrImg = rgb2ycbcr(RGBImg);
YCbCrAvg = signalExtraction(frameNumber, frameTotal, YCbCrImg, YCbCrAvg);