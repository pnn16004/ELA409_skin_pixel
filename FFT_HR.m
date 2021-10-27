function [HR] = FFT_HR(ChAvg,totalFrame)
dim = size(ChAvg, 1);
frameRate = 30;
sec = totalFrame/frameRate;

%For frequnency filtering
freq = 1:totalFrame;
freq = (freq-1)/totalFrame*frameRate;

%Frequency boundaries
lowB = 0/60; % 60 bpm to bps
highB = 180/60; % 120 bpm to bps

%Remove too high or low frequencies
mask = (freq >= lowB & freq <= highB); %Get array where true or false
maskCh = repmat(mask,dim,1); %Copy for each color channel

%Fast Fourier Transform
X = fft(ChAvg, [], 2); %FFT along each row

%Temporal filtering
X_TF = X;
X_TF(~maskCh) = 0; %Filter out the freqs not within bpm range

%Convert back to time domain
ChAvgFilt = real(ifft(X_TF, [], 2)); %IFFT along each row

%Transform
data = mean(ChAvgFilt, 1); %Get the mean of each row
pks = findpeaks(data, 'MinPeakHeight', 0); %Get array containing only the local maximas
%pks = findpeaks(data, 'MinPeakProminence', 1, 'MinPeakHeight', 40);

%Compute bpm by using the amount of times the data "spikes"
numPks = length(pks);
HR = 60 *(numPks/sec); %Make it in minutes
end