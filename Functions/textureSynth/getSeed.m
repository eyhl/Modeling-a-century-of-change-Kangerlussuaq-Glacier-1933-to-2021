function seed=getSeed(I,width)
%getSeed function: return random seed from given image I. The seed is
%[width x width] pixels.
%Input:
%   -I: input image
%   -width: side length of seed patch [width x width]
%Output:
%   -seed: random seed from given image [width x width] pixels.
%Usage:
%   seed=getSeed(I,3);
%Author: Mahmoud Afifi, York University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

randRow=randi(size(I,1)-width); %get random row [1 image's height-width]
randColumn=randi(size(I,2)-width); %get random column [1 image's width-width]
seed(:,:,:)=I(randRow:randRow+width,randColumn:randColumn+width,:);
end