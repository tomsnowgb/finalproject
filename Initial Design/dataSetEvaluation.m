%% Training Size Infomation

clear 
clc 

%% Create Data Sources

dataTrainDir = fullfile(pwd ,'train');
dataValDir = fullfile(pwd ,'validate');

imDir = fullfile(dataTrainDir,'images');
heights = fullfile(dataTrainDir,'heights');
pxDir = fullfile(dataTrainDir,'labels');

classNames = [ "Flood" "NoFlood" ];
pixelLabelID = [0 1];

imds = imageDatastore(imDir);
heights = imageDatastore(heights);

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

trainData1 = combine( imds, heights , pxds);
trainData2 = combine( heights , imds , pxds);

imDir = fullfile(dataValDir,'images');
heights = fullfile(dataValDir,'heights');
pxDir = fullfile(dataValDir,'labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

evaldata1 = combine( imds, heights, pxds);
evaldata2 = combine(heights, imds, pxds);

%% Define L Graph
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


% clean up helper variable
lgraph = connectLayers(lgraph,"relu_1_1","addition/in2");
lgraph = connectLayers(lgraph,"relu_1_2","addition/in1");

    options = trainingOptions('sgdm', ...
                    'MaxEpochs',200,...
                    'InitialLearnRate',0.01, ...
                    'Verbose',false, ...
                    'ValidationData',trainData1);
%% Partition the Training Set
trainData1 = shuffle(trainData1);
count = 0;
results = zeros(1 , 5);
for part = 1:1:5
    count = count + 1;
    subds = subset(trainData1,1:(part*2)); 

     [net,info] = trainNetwork(subds , lgraph , options);
      precisionMetric(net)
      results(count) = info.precisionMetric(net)
end



bar(results)
labels = [5100 10200 15300 20400 25600]
results = [8.3976 9.5549 21.9585 0.0593 0]
plot(labels,results)
xlabel('Number of Labels')
ylabel('Precision')
title('Size of Training Labels vs Precision')