function [kernel,mask]=getROI(I,map,py,px,kS)

%getROI function: get the region of interest based on the given kernel.
%Input:
%   -I: input image
%   -map: logical map
%   -py: y coord of the current pixel
%   -px: x coord of the current pixel
%   -Ks: kernel size [KsxKs] 
%Output:
%   -kernel: ROI patch
%   -mask: corresponding region in the logical map
%Usage:
%   [kernel,mask]=getROI(I,map,29,51,5);
%Author: Mahmoud Afifi, York University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

half=floor(kS/2);
kernel=I(py-half:py+half,px-half:px+half,:);
mask=map(py-half:py+half,px-half:px+half,:);

end