clear
clc
close all

dataDir = fullfile(pwd ,'train');
imDir = fullfile(dataDir,'Images');
heights = fullfile(dataDir,'Heights');
pxDir = fullfile(dataDir,'Labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);

classNames = [ "Flood" "NoFlood" ];
pixelLabelID = [0 1];

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
tbl = countEachLabel(pxds);

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
tbl2 = countEachLabel(pxds);

lgraph = layerGraph();

tempLayers = [
    imageInputLayer([76 150 3],"Name","imageinput_1")
    convolution2dLayer([3 3],64,"Name","conv_1_1","Padding",[1 1 1 1])
    reluLayer("Name","relu_1_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    imageInputLayer([76 150 1],"Name","imageinput_2")
    convolution2dLayer([3 3],64,"Name","conv_1_2","Padding",[1 1 1 1])
    reluLayer("Name","relu_1_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    additionLayer(2,"Name","addition")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Stride",[2 2])
    convolution2dLayer([3 3],64,"Name","conv_2_1","Padding",[1 1 1 1])
    reluLayer("Name","relu_2_1")
    transposedConv2dLayer([4 4],64,"Name","transposed-conv_1","Cropping",[1 1 1 1],"Stride",[2 2])
    convolution2dLayer([1 1],2,"Name","conv_3_1")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Stride",[2 2])
    convolution2dLayer([3 3],64,"Name","conv_2_2","Padding",[1 1 1 1])
    reluLayer("Name","relu_2_2")
    transposedConv2dLayer([4 4],64,"Name","transposed-conv_2","Cropping",[1 1 1 1],"Stride",[2 2])
    convolution2dLayer([1 1],2,"Name","conv_3_2")
    softmaxLayer("Name","softmax")
    pixelClassificationLayer("Name","classoutput")];
lgraph = addLayers(lgraph,tempLayers);

lgraph = connectLayers(lgraph,"relu_1_1","addition/in2");
lgraph = connectLayers(lgraph,"relu_1_2","addition/in1");