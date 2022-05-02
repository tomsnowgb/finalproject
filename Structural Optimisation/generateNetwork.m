function [network] = generateNetwork(gene)

    activationFuncOpts = {leakyReluLayer('Name' , '') , reluLayer()  , softplusLayer('Name' , '') }; %,
    finalLayerOpts = {  pixelClassificationLayer("Name","") ,  focalLossLayer("Name","") ,  dicePixelClassificationLayer("Name","") }; 
    
    %% Select Genes
    depthCells = gene(1);

    additionalCellSat = gene(2);
    additionalCellTop = gene(3);
    
    finalFunc = gene(4);
    activationFuncIdx = gene(5);

    lgraph = layerGraph();
    
    %% Define Sat Image Input
    if additionalCellSat == 1
    satImageInput = [
        imageInputLayer([76 150 3],"Name","imageinput_1")
        convolution2dLayer([3 3],64,"Name","conv_1_1","Padding",[1 1 1 1])
        reluLayer("Name","relu_1_1")];

    elseif additionalCellSat == 2
        satImageInput = [
        imageInputLayer([76 150 3],"Name","imageinput_1")
        convolution2dLayer([3 3],64,"Name","conv_1_0_1","Padding",[1 1 1 1])
        reluLayer("Name","relu_0_1")
        maxPooling2dLayer([2 2],"Stride",[2 2], "Name","maxS")
        convolution2dLayer([3 3],64,"Padding",[1 1 1 1] ,"Name","conv_1_0_2")
        activationFuncOpts{activationFuncIdx}
        transposedConv2dLayer([4 4],64,"Cropping",[1 1 1 1],"Stride",[2 2])
        reluLayer("Name","relu_1_1")
        ];

    else
            satImageInput = [
        imageInputLayer([76 150 3],"Name","imageinput_1")
        convolution2dLayer([3 3],64,"Name","conv_1_0_1","Padding",[1 1 1 1])
        reluLayer("Name","relu_0_1")
        maxPooling2dLayer([2 2],"Stride",[2 2], "Name","maxS")
        convolution2dLayer([3 3],64,"Padding",[1 1 1 1] ,"Name","conv_1_0_2")
        transposedConv2dLayer([4 4],64,"Cropping",[1 1 1 1],"Stride",[2 2])
        reluLayer("Name","relu_1_1")
        ];  
    end 
    
    lgraph = addLayers(lgraph,satImageInput);
    
    %% Define Top Image Input
      

    if additionalCellTop == 1
        topImageInput = [
            imageInputLayer([76 150 1],"Name","imageinput_2")
            convolution2dLayer([3 3],64,"Name","conv_1_2","Padding",[1 1 1 1])
            reluLayer("Name","relu_1_2")];

    elseif additionalCellTop == 2
        topImageInput = [
            imageInputLayer([76 150 1],"Name","imageinput_2")
            convolution2dLayer([3 3],64,"Name","conv_2_0_1","Padding",[1 1 1 1])
            reluLayer("Name","relu_0_2")
            maxPooling2dLayer([2 2],"Stride",[2 2], "Name","maxT")
            convolution2dLayer([3 3],64,"Padding",[1 1 1 1] ,"Name","conv_2_0_2")
            activationFuncOpts{activationFuncIdx}
            transposedConv2dLayer([4 4],64,"Cropping",[1 1 1 1],"Stride",[2 2])
            reluLayer("Name","relu_1_2")
            ];

    else
        topImageInput = [
            imageInputLayer([76 150 1],"Name","imageinput_2")
            convolution2dLayer([3 3],64,"Name","conv_2_0_1","Padding",[1 1 1 1])
            reluLayer("Name","relu_0_2")
            maxPooling2dLayer([2 2],"Stride",[2 2], "Name","maxT")
            convolution2dLayer([3 3],64,"Padding",[1 1 1 1] ,"Name","conv_2_0_2")
            transposedConv2dLayer([4 4],64,"Cropping",[1 1 1 1],"Stride",[2 2])
            reluLayer("Name","relu_1_2")
            ];
    end
    

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
        finalLayerOpts{finalFunc}
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

        network = lgraph;
end

