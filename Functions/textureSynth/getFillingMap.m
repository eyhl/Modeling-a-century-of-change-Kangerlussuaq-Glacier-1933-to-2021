function map=getFillingMap(I,Hcolor)

%getFillingMap function: return the filling map of the input image I. 
%Input:
%   -I: input image
%   -Hcolor: color of hole pixels
%Output:
%   -map: filled map (logical)
%Usage:
%   map=getFillingMap(image,[0,0,0]);
%Author: Mahmoud Afifi, York University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
map=true(size(I,1),size(I,2));
for i=1:size(I,3)
    map=map&(I(:,:,i)~=Hcolor(i));
end
