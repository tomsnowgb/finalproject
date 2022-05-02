%% Evolutionary Optimisation
clear 
clc
%% Dataset Setup
[trainData1, evaldata1] = setup();
maxEpochs = 2;
maxPopulation = 5;
maxGenes = 5;

epoch = 1;

%% Initial Space
    %% Generate L Graphs
    results = zeros(maxEpochs ,maxPopulation);
    geneList =  zeros(maxEpochs,maxGenes , maxPopulation);
    for networks = 1:maxPopulation
        gene = [0 0 0 0 0];

        % Number of Cells Main
        % 1 2 3 4
        gene(1) = randi(4);

        % Additional Cell Left
        % True False
        gene(2) = randi(3);
    
        % Additional Cell Right
        % True False
        gene(3) = randi(3);
    
        % Loss Function
        % CE FL DICE
        gene(4) = randi(3);
    
        % Activation Function
        % Leaky ReLU % ReLU % Softplus
        gene(5) = randi(3);
        
        geneList(epoch, : , networks) = gene;
        %% Generate Network
            lgraph = generateNetwork(gene);

        %% Train Network
            
         options = trainingOptions('sgdm', ...
                    'MaxEpochs',5,...
                    'InitialLearnRate',0.01, ...
                    'Verbose',false, ...
                    'ValidationData',evaldata1);

         [net,info] = trainNetwork(trainData1 , lgraph , options);

        %% Evaluate Network
        gene
        results(epoch , networks) = FMetric(net)
    end
    

    for furtherEpochs = 2:maxEpochs
        %% Sort Networks
        tempResults = results(epoch,:);
        [~,I] = max(tempResults);

        tempResults(I) = -1;

        gene1 = geneList(epoch , : , I);

        [~,I] = max(tempResults);

        gene2 = geneList(epoch, : , I);

        %% Perform Evolutionary Changes
        epoch = furtherEpochs;
        genePair = cat(1 ,gene1,gene2);

        for networks = 1:maxPopulation

            gene = [0 0 0 0 0];

            % Number of Cells Main
            % 1 2 3 4
            gene(1) = genePair(randi(2),1);

            % Additional Cell Left
            % True False
            gene(2) = genePair(randi(2),2);

            % Additional Cell Right
            % True False
            gene(3) = genePair(randi(2),3);

            % Loss Function
            % CE FL
            gene(4) = genePair(randi(2),4);

            % Activation Function
            % Leaky ReLU % ReLU % Softplus
            gene(5) = genePair(randi(2),5);

            %% Add Randomness

            if rand(1) > 0.5
                idx = randi(5);
                gene(idx) = geneList(epoch -1 , idx , networks);
            end


            geneList(epoch ,: , networks) = gene;
            lgraph = generateNetwork(gene);

            %% Train Network

            [net,info] = trainNetwork(trainData1 , lgraph , options);

            %% Evaluate Network

            results(epoch , networks) =  FMetric(net);
        end
    end



function [trainData1, evaldata1] = setup()
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
    
    imDir = fullfile(dataValDir,'images');
    heights = fullfile(dataValDir,'heights');
    pxDir = fullfile(dataValDir,'labels');
    
    imds = imageDatastore(imDir);
    heights = imageDatastore(heights);
    
    pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
    
    evaldata1 = combine( imds, heights, pxds);
end


function [out] = FMetric(net)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


dataDir = fullfile(pwd ,'validate');
imDir = fullfile(dataDir,'images');
heights = fullfile(dataDir,'heights');
pxDir = fullfile(dataDir,'labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);
risk = imageDatastore(pxDir);

classNames = ["Flood" "NoFlood"  ];
pixelLabelID = [0 1];
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

evaldata = combine( imds , heights);
testSeg = predict(net , evaldata);

outputs = double.empty;
labels = double.empty;


for idx = 1:16
    str = ones(76 , 150);
    cmData = zeros(76 , 150);


    cmData(testSeg(: , : ,2 , idx) > testSeg(: , :, 1 , idx) ) =  str(testSeg(: , : ,2 , idx) > testSeg(: , :, 1 , idx));
    outputs = cat(1 , outputs ,  reshape(cmData,[],1));


    predictor = risk.readimage(idx);
    labels = cat(1 , labels ,  reshape(predictor,[],1));

end

cmData  = confusionmat(labels,outputs);
precision = (cmData(1 , 1) / ( cmData(1 , 1) + cmData(1 , 2)));
recall = (cmData(1 , 1) / ( cmData(1 , 1) + cmData(2 , 1)));

out = (2 * precision * recall)/(precision + recall);

if isnan(out)
    out = 0;
end
end


