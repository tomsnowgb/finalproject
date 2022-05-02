%%clear
clc
close all

dataDir = fullfile(pwd ,'train');
imDir = fullfile(dataDir,'images');
heights = fullfile(dataDir,'heights');
pxDir = fullfile(dataDir,'labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);

classNames = [ "Flood" "NoFlood" ];
pixelLabelID = [0 1];

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
tbl = countEachLabel(pxds)

trainData1 = combine( imds, heights , pxds);
trainData2 = combine( heights , imds , pxds);

dataDir = fullfile(pwd ,'validate');
imDir = fullfile(dataDir,'images');
heights = fullfile(dataDir,'heights');
pxDir = fullfile(dataDir,'labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);

classNames = [ "Flood" "NoFlood" ];
pixelLabelID = [0 1];
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

evaldata1 = combine( imds, heights, pxds);
evaldata2 = combine(heights, imds, pxds);
tbl2 = countEachLabel(pxds)

figure 
frequency = tbl.PixelCount/sum(tbl.PixelCount);

bar(1:numel(classNames),frequency)
xticks(1:numel(classNames)) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')


figure 
frequency = tbl2.PixelCount/sum(tbl2.PixelCount);

bar(1:numel(classNames),frequency)
xticks(1:numel(classNames)) 
xticklabels(tbl2.Name)
xtickangle(45)
ylabel('Frequency')