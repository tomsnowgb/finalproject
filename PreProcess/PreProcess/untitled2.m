
im = imread('TEST.tif');

imgray = im2gray(im);
bw = imbinarize(imgray , 0);




BW2 = bwmorph(imcomplement(bw),'thicken',1);

BW2=bwmorph(BW2,'bridge'); 

se = strel('line',3,180);  % Structuring element for dilation
BW2 = imdilate(BW2,se);    




n = ones(75 , 150 , 3); 
imOut = im;

v(: , : , 1 ) = imcomplement(BW2);



R = imOut(: , : , 1);
G = imOut(: , : , 2);
B = imOut(: , : , 3);


R(v(: , : ,1) == 0) = 0;
G(v(: , : ,1) == 0) = 0;
B(v(: , : ,1) == 0) = 255;



imOut(: , : , 1) = R;
imOut(: , : , 2) = G;
imOut(: , : , 3) = B;
imOut = imresize(imOut , [76 150]);
