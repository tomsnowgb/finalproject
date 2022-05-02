%% Structure Optimisation

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

activationFuncOpts = {reluLayer()  }; %, softplusLayer('Name' , '')
finalLayerOpts = {  pixelClassificationLayer("Name","") ,  focalLossLayer("Name",'') ,   }; %, softplusLayer('Name' , '')
results = zeros(size(finalLayerOpts , 2) , size(activationFuncOpts , 2) , 4);

%%
for depthCells = 1:4
    for activationFuncIdx = 1:size(activationFuncOpts , 2)
        for finalFuncIdx = 1:size(finalLayerOpts , 2)
            lgraph = layerGraph();

            %% Define Sat Image Input
            satImageInput = [
                imageInputLayer([76 150 3],"Name","imageinput_1")
                convolution2dLayer([3 3],64,"Name","conv_1_1","Padding",[1 1 1 1])
                reluLayer("Name","relu_1_1")];

            lgraph = addLayers(lgraph,satImageInput);

            %% Define Top Image Input
            topImageInput = [
                imageInputLayer([76 150 1],"Name","imageinput_2")
                convolution2dLayer([3 3],64,"Name","conv_1_2","Padding",[1 1 1 1])
                reluLayer("Name","relu_1_2")];

            lgraph = addLayers(lgraph,topImageInput);

            %% Add Additon Input Network
            addInitLayer = additionLayer(2,"Name","addition");

            %% Define Cell Layer
            cellLayer = [
                maxPooling2dLayer([2 2],"Stride",[2 2])
                convolution2dLayer([3 3],64,"Padding",[1 1 1 1])
                activationFuncOpts{activationFuncIdx}
                transposedConv2dLayer([4 4],64,"Cropping",[1 1 1 1],"Stride",[2 2])
                convolution2dLayer([1 1],2)
                ];


            finalLayers = [
                softmaxLayer("Name","softmax")
                finalLayerOpts{finalFuncIdx}
                ];

                lgraph = addLayers(lgraph, addInitLayer);
                lgraph = addLayers(lgraph,finalLayers);

                lgraph = addLayers(lgraph , cellLayer);

                if depthCells ~= 1
                for counter = 2:depthCells
                    lgraph = addLayers(lgraph , cellLayer);

                    temp = 2*counter - 2;
                    lgraph = connectLayers(lgraph, strcat("conv_" , int2str(temp)),strcat("maxpool_" , int2str(counter -1 )));

                end
                else
                    counter = 1;
                end


                lgraph = connectLayers(lgraph, strcat("conv_" , int2str(counter*2)),"softmax");



                lgraph = connectLayers(lgraph,"relu_1_1","addition/in2");
                lgraph = connectLayers(lgraph,"relu_1_2","addition/in1");
                lgraph = connectLayers(lgraph,"addition","maxpool");





                options = trainingOptions('sgdm', ...
                    'MaxEpochs',250,...
                    'InitialLearnRate',0.01, ...
                    'Verbose',false, ...
                    'ValidationData',evaldata1);

                %[net,info] = trainNetwork(trainData1 , lgraph , options);

                %results(finalFuncIdx,activationFuncIdx,depthCells) = precisionMetric(net);

        end
    end
end



data = [results(:,:,1)'; results(:,:,2)'; results(:,:,3)'; results(:,:,4)';]
bar(data)