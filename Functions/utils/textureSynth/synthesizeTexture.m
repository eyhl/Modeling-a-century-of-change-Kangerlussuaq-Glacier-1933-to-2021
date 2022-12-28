function result=synthesizeTexture(I, fillingOption, kS, nW, nH,show)

%synthesizeTexture function: implementation of "texture synthesis by non-
%parametric sampling" paper. The function provides two options, the first
%one is texture growing, and the second one is hole filling. You can
%control that using fillingOption arguement.
%Input:
%   -I: sample texture image
%   -fillingOption: 1 (yes) 0 (no)
%   -kS: kernel size
%   -nW: for texture growning (fillingOption=0), it represents the new
%   width. For hole filling, it is used as color of hole pixels (R,G,B).
%   -nH: for texture growning (fillingOption=0), it represents the new
%   height
%   -show: 1 for update screen with each new pixel, 0 for working
%   off-screen (default = 0)
%Output:
%   -result: resulting image (uint8)
%Usage:
%   result=synthesizeTexture(I,0,5,300,400); %texture growing
%   result=synthesizeTexture(I,0,5,300,400,1); %texture growing (update screen)
%   result=synthesizeTexture(I,1,5); %hole filling using [0,0,0] for hole color
%   result=synthesizeTexture(I,1,5,[1,0,0]); %hole filling using red as color of hole pixles

%Citation: Texture synthesis by non-parametric sampling." Computer Vision,
%1999. The Proceedings of the Seventh IEEE International Conference on. Vol.
%2. IEEE, 1999
%Author: Mahmoud Afifi, York University

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%check
if nargin<4 && fillingOption==0
    error('Too few input arguments');
elseif nargin<4 && fillingOption==1
    nW=[0,0,0]; %black color
    nH=0;
elseif nargin==5
    show=0;
end
if mod(kS,2)==0
    kS=kS+1;
end

%%
%General initialization
display('initialization...');
I=double(I)/255; %from uint8 to normalized double
seedSize = 3; %seed size
sigma = kS/6; %proportional to the window size

G = fspecial('gaussian', [kS kS], sigma); %gaussian weighting kernel
G=G(:); %convert it to 1-d
eps = 0.1; %error threshold

if fillingOption==0 && (nW<seedSize || nH<seedSize) %if new dimensions less than the seed
    error('Choose larger width and/or height') %report error!
elseif fillingOption==1
    Hcolor=nW; %make color of hole pixels = nW variable
end
[cH, cW, c] = size(I); %get current height, width, and number of color channels

%Initialize candidate patchs: zeros (number of element per patch, number of
%candidate patchs, number of color channels)
cPatchs=zeros(kS*kS, (cW-kS+1) * (cH-kS+1), c);
%get candidate patchs
for cC = 1:c %for each color channel do
    cPatchs(:,:,cC) = im2col(I(:,:,cC), [kS kS], 'sliding'); %get all possible sliding windows
end
%creat a map that indicates whether the pixel is filled or not
if fillingOption==0 %if it is texture growing, start with empty map; result size [nH,nW]
    result=zeros(nH,nW,c); %output image
    map=false(nH,nW); %filled map
    %pick random seed [seedSize x seedSize]
    seed=getSeed(I,kS);
    %put it in the ceneter of the new image
    result(round(nH/2)-floor(kS/2):round(nH/2)+ceil(kS/2),...
        round(nW/2)-floor(kS/2):round(nW/2)+ceil(kS/2),:)=seed;
    %raise flag of corresponding pixels in the filled map to be 'on'
    map(round(nH/2)-floor(kS/2):round(nH/2)+ceil(kS/2),...
        round(nW/2)-floor(kS/2):round(nW/2)+ceil(kS/2),:)=1;
    
else %otherwise, get map from the image and make the result with the same size of I
    result=I; %result image with the same size
    map=getFillingMap(I,Hcolor); %generate map from input image
    %remove hole pixels from the candidate patchs
    cPatchs=cleanCPatchs(cPatchs,Hcolor);
end

%prepare the candidate patchs for a single operation of distance
%measurement 
cPatchs=[cPatchs(:,:,1);cPatchs(:,:,2);cPatchs(:,:,3)];%concate three color channels to use 1-d vector for each candidate

%padding both result and map to access pixels at corners
padded_result = padarray(result, [floor(kS/2) floor(kS/2)]);
padded_map = padarray(map, [floor(kS/2) floor(kS/2)]);

%preparing the Gaussian kernel to be 1-D for a single operation of distance
%measurement
G=repmat(G, 1,size(cPatchs, 2)); %repeat it to match the number of candidate patchs
%take into account color channels.
st='G=[';
for cC=1:c-1
    st=strcat(st,'G;');
end
st=strcat(st,'G];');
eval(st);

%%
%Processing
display('processing...');

% while there are unfilled pixels, do
while ~all(all(map))
    %get nearest pixels for the known pixels (boundary)
    se = strel('square', 3);
    dilated_map = imdilate(map, se);
    surrounding_map = dilated_map - (map);
    unfilledIndicies=find(surrounding_map==1); % find unfilled pixels
    for p=1:length(unfilledIndicies) %for each pixel of unfilled pixels, do
        [py, px] = ind2sub(size(map),unfilledIndicies(p)); %get corresponding in x,y coordinate
        % get neighborhood pixels of the current unknown pixel using the kernel
        [kernel,mask]=getROI(padded_result,padded_map,py+floor(kS/2),px+floor(kS/2),kS);
        
        %prepare kernel, and mask to do single operation for all candidates
        kernel=kernel(:); %1-d
        mask=mask(:); %1-d
        %take into account color channels.
        st='mask=[';
        for cC=1:c-1
            st=strcat(st,'mask;');
        end
        st=strcat(st,'mask];');
        eval(st);
        kernel=repmat(kernel, 1,size(cPatchs, 2)); %repeat it to match the number of candidate patchs
        mask=repmat(mask, 1,size(cPatchs, 2)); %repeat it to match the number of candidate patchs
        
        %calculate weighted sum squared distance between the kernel and all
        %candidaate patchs.
        dSSD=sum(mask.*G.*(cPatchs-kernel).^2);
        minD = min(dSSD);
        T = minD*(1+eps); %to avoid zero match, let's accept more candidates (read the paper section 2.1)
        
        %get indicies of all accepted candidate patchs (distances less than T)
        indicies=find(dSSD<=T);
        
        %pick random patch from the accpeted candidate patchs
        index=indicies(randi(length(indicies))); %index
        patch=cPatchs(:,index); %get the patch
        patch=reshape(patch,[kS,kS,c]); %reshape it
        
        %get the new pixel
        newPixel=patch(ceil(kS/2),ceil(kS/2),:); %get the middle pixel of the patch
        
        %update result and map
        result(py,px,:)=newPixel; %add it to the synthetic texture image
        padded_result(floor(kS/2)+py,floor(kS/2)+px,:)=newPixel; %update the padded result
        map(py,px,:)=1; %raise flag of corresponding pixels in the map
        padded_map(floor(kS/2)+py,floor(kS/2)+px,:)=1; %update the padded map
    end
    %show
    if show==1
        imshow(result);
    end
end
end