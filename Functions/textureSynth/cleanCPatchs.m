function new_cPatchs=cleanCPatchs(cPatchs,Hcolor)
%cleanCPatchs function: discard any candidate patch that has a pixel with
%the given color Hcolor.
%Input:
%   -cPatchs: [NxMxC] candidate patchs. N is the number of element (pixels)
%   per patch. M is the number of candidates. C is the number of color
%   channel.
%   -Hcolor: color of hole pixels
%Output:
%   -new_cPatchs: new candidate patchs after removing patchs that contain
%   pixels with the target color Hcolor.
%Usage:
%   new_cPatchs=cleanCPatchs(cPatchs,[0,0,0]);
%Author: Mahmoud Afifi, York University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(Hcolor)==3
[u,v,d]=find(cPatchs(:,:,1)==Hcolor(1) & cPatchs(:,:,2)==Hcolor(2) & cPatchs(:,:,3)==Hcolor(3));
else
    [u,v,d]=find(cPatchs(:,:,1)==Hcolor );
end
new_cPatchs= cPatchs(:,setdiff([1:size(cPatchs,2)]',unique(v)),:);