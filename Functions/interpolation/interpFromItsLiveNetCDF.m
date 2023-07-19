function dataout = interpFromItsLiveNetCDF(mesh_x,mesh_y,Tstart,Tend,varargin)
    %interpFromItsLiveNetCDF: 
    %	This function calls src/m/contrib/morlighem/modeldata/interpFromGeotiff.m for multiple times to load all avaliable 
    %	tif data in  /totten_1/ModelData/Greenland/VelMEaSUREs/Jakobshavn_2008_2021/ within the given time period (in decimal years)
    %	For some reason, each .tif file in this folder contains two sets of data, only the first dataset is useful
    %
    %   Usage:
    %		 dataout = interpFromMEaSUREsGeotiff(X,Y,Tstart,Tend, varargin)
    %
    %	X, Y are the coordinates of the mesh 
    %	Tstart and Tend decimal year of the start and end time
    %
    %   Example:
    %			obsData = interpFromMEaSUREsGeotiff(md.mesh.x,md.mesh.y, tstart, tend);
    %
    %   Options:
    %      - 'glacier':  which glacier to look for
    % AUTHOR: EIGIL

    options    = pairoptions(varargin{:});
    glacier    = getfieldvalue(options,'glacier','Jakobshavn');
    
    if strcmp(glacier, 'Kangerlussuaq')
        foldername = '/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/image_pairs/';
    else
        error(['The velocity data for ', glacier, ' is not available, please download from NSIDC first.']);
    end
    
    % get the time info from file names
    templist = dir(fullfile('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/image_pairs/', '*.nc'));
    Ndata = length(templist);
    dataTstart = zeros(Ndata,1);
    dataTend = zeros(Ndata,1);
    
    for i = 1:Ndata
        tempConv = split(templist(i).name, '_');
        % follow the naming convention
        dataPrefix(i) = join(tempConv, '_');
        dataTstart(i) = date2decyear(datenum(tempConv{1}(15:end-4), 'yyyymmdd'));
        dataTend(i) = date2decyear(datenum(tempConv{2}(15:end-4), 'yyyymmdd'));
    end
    disp(['  Found ', num2str(Ndata), ' records in ', foldername]);
    disp(['    from ', datestr(decyear2date(min(dataTstart)),'yyyy-mm-dd'), ' to ', datestr(decyear2date(max(dataTend)),'yyyy-mm-dd') ]);
    
    
    % find all the data files with Tstart<=t<=Tend
    dataInd = (dataTend>=Tstart) & (dataTstart<=Tend);
    disp([' For the selected period: ', datestr(decyear2date((Tstart)),'yyyy-mm-dd'), ' to ', datestr(decyear2date((Tend)),'yyyy-mm-dd'), ', there are ', num2str(sum(dataInd)), ' records' ]);
    
    dataToLoad = dataPrefix(dataInd);
    TstartToload = dataTstart(dataInd);
    TendToload = dataTend(dataInd);
    dataout = struct('vel', [], 'vx', [], 'vy', [], 'Tstart', [], 'Tend', []);
    j = 1;
    for i = 1:length(dataToLoad)
        file_path = fullfile(templist(1).folder, dataToLoad(i));
        file_path = file_path{1};
        vel = ncread(file_path, 'v');
        vx = ncread(file_path, 'vx');
        vy = ncread(file_path, 'vy');
        x = ncread(file_path,'x');
        y = ncread(file_path,'y');
        [X, Y] = ndgrid(x, y);

        vel(vel==-32767) = nan;
        F = griddedInterpolant(X, fliplr(Y), fliplr(vel), 'linear', 'none');
        vel_tmp = F(mesh_x, mesh_y);
        % check that there is more than 1% of the data
        if sum(~isnan(vel_tmp(:)))/numel(vel_tmp) < 0.01
            fprintf('Less than 1%% of the data is available for %d, skipping', i)
            % keep track of how many iterations are skipped
            skipped(j) = i;
            j = j + 1;
            continue
        end
        fprintf('Loading and interpolating %ds\n', dataToLoad(i))
        dataout(i).vel = vel_tmp; 

        vel(vx==-32767) = nan;
        F = griddedInterpolant(X, fliplr(Y), fliplr(vel), 'linear', 'none');
        dataout(i).vx = F(mesh_x, mesh_y); 

        vel(vy==-32767) = nan;
        F = griddedInterpolant(X, fliplr(Y), fliplr(vel), 'linear', 'none');
        dataout(i).vy = F(mesh_x, mesh_y); 

        dataout(i).Tstart = TstartToload(i);
        dataout(i).Tend = TendToload(i);
    end

    % print status on how many files where used in total
    fprintf('Total number of files used: %d\n', length(dataToLoad)-length(skipped))
    fprintf('Total number of files skipped: %d\n', length(skipped))
    save('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/image_pairs_onmesh_1985.mat', 'dataout');
end