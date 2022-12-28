%Demo

% %texture1
% fileName='texture1.bmp';
% I=imread(fileName);
% newWidth=500;
% newHeight=400;
% filling=0;
% kernel_size=21;
% show=1;
% result=synthesizeTexture(I,filling,kernel_size,newWidth,newHeight,show);
% figure; imshow(result);
% imwrite(result,strcat(fileName(1:end-4),'_Results.bmp'));

% %texture2
% fileName='texture2.bmp';
% I=imread(fileName);
% newWidth=500;
% newHeight=400;
% filling=0;
% kernel_size=21;
% show=1;
% result=synthesizeTexture(I,filling,kernel_size,newWidth,newHeight,show);
% figure; imshow(result);
% imwrite(result,strcat(fileName(1:end-4),'_Results.bmp'));

% % %english
% fileName='english.jpg';
% I=imread(fileName);
% newWidth=400;
% newHeight=220;
% filling=0;
% kernel_size=33;
% show=1;
% result=synthesizeTexture(I,filling,kernel_size,newWidth,newHeight,show);
% figure; imshow(result);
% imwrite(result,strcat(fileName(1:end-4),'_Results.bmp'));

% % fill1
% fileName='fill1.bmp';
% I=imread(fileName);
% filling=1;
% kernel_size=11;
% show=1;
% result=synthesizeTexture(I,filling,kernel_size,[0,0,0],0,show);
% figure; imshow(result);
% imwrite(result,strcat(fileName(1:end-4),'_Results.bmp'));


% % fill2
fileName='fill2.bmp';
I=imread(fileName);
filling=1;
kernel_size=5;
show=1;
result=synthesizeTexture(I,filling,kernel_size,[0,0,0],0,show);
figure; imshow(result);
imwrite(result,strcat(fileName(1:end-4),'_Results.bmp'));


