function [out] = precisionMetric(net)
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


for idx = 1:4
    str = ones(76 , 150);
    cmData = zeros(76 , 150);
    
    
    cmData(testSeg(: , : ,2 , idx) > testSeg(: , :, 1 , idx) ) =  str(testSeg(: , : ,2 , idx) > testSeg(: , :, 1 , idx));
    outputs = cat(1 , outputs ,  reshape(cmData,[],1));

    
    predictor = risk.readimage(idx);
    labels = cat(1 , labels ,  reshape(predictor,[],1));
    
end 





 cmData  = confusionmat(labels,outputs);
 out = (cmData(1 , 1) / ( cmData(1 , 1) + cmData(1 , 2))) * 100;

end