close all

x = imread('Height.tif');
y = imread('Risk.tif');


figure
imshow(y)



figure 
surface(x)
xlabel('X Pixel Index')
ylabel('Y Pixel Index')
zlabel('Height (Arbitary Scale)')
title('Surface of Topographical Data')


figure
surf(x , 'cdata',double(y))
map = [0 0 243
13 255 243];
map = uint8(map);
cmap = colormap(map);
pixelLabelColorbar(cmap , ["Flood" ,"No Flood"]);
title('Labelled Surface of Topographical Data')
xlabel('X Pixel Index')
ylabel('Y Pixel Index')
zlabel('Height (Arbitary Scale)')


%%
figure
y = imread('SatDataMod.tiff');
imshow(y)
