%% Prototype Evaluation


clear
close all
%load updatedNetwork.mat

net = trainedNetwork_1;

dataDir = fullfile(pwd ,'validate');
imDir = fullfile(dataDir,'images');
heights = fullfile(dataDir,'heights');
pxDir = fullfile(dataDir,'labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);
evalRisk = imageDatastore(pxDir);

classNames = ["Flood" "NoFlood"  ];
pixelLabelID = [0 1];

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

evaldata1 = combine( imds  , heights );
evaldata2 = combine(heights , imds   );

dataDir = fullfile(pwd ,'train');
imDir = fullfile(dataDir,'Images');
heights = fullfile(dataDir,'Heights');
pxDir = fullfile(dataDir,'Labels');

imds = imageDatastore(imDir);
heights = imageDatastore(heights);
trainRisk = imageDatastore(pxDir);

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

trainData1 = combine( imds, heights );
trainData2 = combine( heights , imds);

testSeg = predict(net , evaldata1);

outputs = double.empty;
labels = double.empty;
for idx = 1:4
    str = ones(76 , 150);
    out = zeros(76 , 150);
    
    add = 0;
    out(testSeg(: , : ,2 , idx) > testSeg(: , :, 1 , idx) + add) =  str(testSeg(: , : ,2 , idx) > (testSeg(: , :, 1 , idx) + add));
    outputs = cat(1 , outputs ,  reshape(out,[],1));
%      figure("Name", int2str(idx))
%     imshow(out)
    
    
    predictor = evalRisk.readimage(idx);
    labels = cat(1 , labels ,  reshape(predictor,[],1));
    
%      figure("Name", int2str(idx))
%      imshow(predictor)

 figure
  imshowpair(out, predictor );

 xLabel = sprintf( ['\\fontsize{11}',...
     '{\\color{black}%s} True Positives      ',...
     '{\\color{magenta}%s} False Positives      ',... 
     '{\\color{green}%s} False Negatives'],... 
     char(9632), char(9632), char(9632));
 xlabel(xLabel);
end 

figure
cm = confusionchart(confusionmat(labels,outputs) , classNames , "Normalization", "total-normalized");

cm.Title = 'Pixel Classification Using Semantic Segmentation';
 cmData = confusionmat(labels,outputs)

 metricOutputF = cmData(1 , 1) / ( cmData(1 , 1) + cmData(1 , 2)) * 100
 metricOutputNF = cmData(2 , 2) / ( cmData(2 , 1) + cmData(2 , 2)) * 100

 average = (metricOutputF + metricOutputNF ) * 0.5