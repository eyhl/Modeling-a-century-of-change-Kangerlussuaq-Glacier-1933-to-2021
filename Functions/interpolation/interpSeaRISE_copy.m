function [dataout] = interpSeaRISE_copy(X,Y,string,path,varargin),
    %INTERPSEARISE - interpolate SeaRISE data
    %
    %   Available data:
    %      1.  sealeveltimes
    %      2.  dhdt
    %      3.  surfvelmag
    %      4.  balvelmag
    %      5.  oisotopestimes
    %      6.  bheatflx
    %      7.  presprcp
    %      8.  sealevel_time_series
    %      9.  usrf
    %      10. mapping
    %      11. surfvely
    %      12. surfvelx
    %      13. topg
    %      14. landcover
    %      15. temp_time_series
    %      16. thk
    %      17. time
    %      18. oisotopes_time_series
    %      19. runoff
    %      20. smb
    %      21. airtemp2m
    %      22. surftemp
    %
    %   Usage:
    %      [dataout] = interpBedmap2(X,Y,string)
    
    verbose=0;
    
    if nargin==3,
        hemisphere = +1;
    else
        hemisphere = varargin{1};
    end
    
    
    %read data
    switch (oshostname()),
        case {'ronne'}
            if hemisphere==1,
                searisenc='/home/ModelData/SeaRISE/Greenland_5km_dev1.2.nc';
            elseif hemisphere==-1,
                searisenc='/home/ModelData/SeaRISE/Antarctica_5km_dev1.0.nc';
            end
        case {'thwaites','murdo','astrid'}
            if hemisphere==1,
                searisenc='/u/astrid-r1b/ModelData/SeaRISE/Greenland5km_v1.2/Greenland_5km_dev1.2.nc';
            elseif hemisphere==-1,
                searisenc='/u/astrid-r1b/ModelData/SeaRISE/Antarctica5km_shelves_v1.0/Antarctica_5km_dev1.0.nc';
            end
        case {'totten'}
            if hemisphere==1,
                searisenc='/totten_1/ModelData/SeaRISE/Greenland_5km_dev1.2.nc';
            elseif hemisphere==-1,
                searisenc='/totten_1/ModelData/SeaRISE/Antarctica_5km_dev1.0.nc';
            end
        case {'oasis'}
            if hemisphere==1,
                searisenc='/data/eigil/work/lia_kq/Data/SeaRISE/Greenland_5km_dev1.2.nc';
            elseif hemisphere==-1,
                error('Not defined for antarctica');
            end
        otherwise
            error('hostname not supported yet');
    end
    
    %convert coordinates to SeaRISE projection
    if verbose, disp('   -- SeaRISE: converting coordinates'); end
    if hemisphere==1,
        [LAT,  LON  ] = xy2ll(double(X(:)),double(Y(:)),+1,45,70);
        [xproj,yproj] = ll2xy(LAT,LON  ,+1,39,71);
    elseif hemisphere==-1,
        xproj=X; yproj=Y;
    end
    
    if verbose, disp('   -- SeaRISE: loading coordinates'); end
    xdata = double(ncread(searisenc,'x1'));%*1000;
    ydata = double(ncread(searisenc,'y1'));%*1000;
    
    if verbose, disp(['   -- SeaRISE: loading ' string]); end
    data  = double(ncread(searisenc,string))';
    
    if verbose, disp(['   -- SeaRISE: interpolating ' string]); end
    if strcmpi(string,'LandMask');
        dataout = InterpFromGrid(xdata,ydata,data,xproj,yproj,'nearest');
    else
        dataout = InterpFromGrid(xdata,ydata,data,xproj,yproj);
    end
    dataout = reshape(dataout,size(X,1),size(X,2));
    

    % function out = interpSeaRISE_copy(mesh_x, mesh_y, part)
% ncdata = "/data/eigil/work/lia_kq/Data/issm_data/Greenland_5km_dev1.2.nc";
% x   = ncread(ncdata,'x1');
% y   = ncread(ncdata,'y1');

% if strcmp(part, 'bheatflx')
%     mask_data = ncread(ncdata, 'bheatflx');
%     out = InterpFromGridToMesh(x, y, mask_data', mesh_x, mesh_y, nan);

% elseif strcmp(part, 'surftemp')
%     bed_data = ncread(ncdata, 'surftemp');
%     out = InterpFromGridToMesh(x, y, bed_data', mesh_x, mesh_y, nan);

% elseif strcmp(part, 'surfvelmag')
%     surface_data = ncread(ncdata, 'surfvelmag');
%     out = InterpFromGridToMesh(x, y, surface_data', mesh_x, mesh_y, nan);
% end

% end