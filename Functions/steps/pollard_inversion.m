function [md, vecmaxdS, vecmindS, vecmeandS] = pollard_inversion(md)
    % Inversion of friction coefficient based on Pollard and DeConto (2012) 
    % "A simple inverse method for the distribution of basal sliding
    % coefficients under ice sheets, applied to Antarctica"
    axs = [0.4317, 0.5152, -2.3190, -2.2178] .* 1e6;

    cluster=generic('name', oshostname(), 'np', 30);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

    % parameters
    k = md.friction.coefficient; %Crude initial guess for basal friction
    k_max = 1e4;
    k_min = 0.01;

    % area to be updated
    aoi = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));
    % aoi = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/pollard_update_area.exp', 2));
    % k(aoi) = 350;

    % adjust
    Sinv		= 1000;
    timeadjust	= 20;
    finaltime	= 1900;
    maxerror	= 0.005; % relative
    nstep		= ceil(finaltime/timeadjust);

    % set timestepping to fixed
    md.timestepping = timestepping();

    % get Sobs (surface) and initial Smodel (surface) on 2D mesh
    Sobs			= md.geometry.surface;

    % % % fix smb forcing to be the average of 1900 for all steps:
    % smb_1900_index = md.smb.mass_balance(end, :) < 1901;

    % % % repeat for 50 years every month:
    % tmp = [repmat(mean(md.smb.mass_balance(1:end-1, smb_1900_index), 2), 1, 12*50); 0:1/12:(50-1/12)];
    % md.smb.mass_balance = [tmp, md.smb.mass_balance];
    if ~round(md.smb.mass_balance(end,1) - 1880) == 0
        error('No 1880 SMB available')
    end

    vecmaxdS		= [];
    vecmindS		= [];
    vecmeandS	= [];
    tic
    for i=1:nstep
        fprintf('CASE: %d.   STEP: %d/%d. \n', 1, i, nstep) 
        
        % set friction coefficient and rheology
        md.friction.coefficient = k;

        md.timestepping.start_time				= 1880.;
        md.timestepping.final_time				= 1880 + timeadjust;
        md.timestepping.time_step				= 0.01;
        md.settings.output_frequency			= timeadjust;
        md.transient.requested_outputs		    = {'default', 'IceVolume','TotalSmb','SmbMassBalance', 'MaskIceLevelset', 'MaskOceanLevelset'};
        md.transient.ismovingfront		        = 0;
        md.verbose								= verbose('convergence',true,'solution',true);

        % meltingrate
        md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices, 1);

        % run forward in time
        md.cluster= cluster;
        md_tmp=solve(md,'Transient');
        % ok, adjust friction according to ice surface error Smodel-Sobs
        md = transientrestart(md_tmp);
        md = sethydrostaticmask(md);
        md = make_floating(md);
        plotmodel(md, 'data', md.initialization.vel, 'data', md.friction.coefficient, 'figure', 22, 'axis#all', axs);
        % plotmodel(md, 'data', md.mask.ice_levelset<0, 'figure', 3);
        % plotmodel(md, 'data', md.mask.ocean_levelset<0, 'figure', 4);
        Smodel	= md.geometry.surface;

        % adjust coefficient
        dS			= Sobs-Smodel;
        [~, ~, dS, ~] = flowline_traceback(md_tmp, dS, false);
        md.geometry.surface =  md.geometry.surface - dS/Sinv;
        md = sethydrostaticmask(md);
        md = make_floating(md);
        
        % dZ			= dS/Sinv;	
        % dZ(aoi)			= max(-1.5,min(1.5,dZ(aoi)));
        % k(aoi)      = k(aoi).*sqrt(10.^dZ(aoi));
        % % dZ			= max(-1.5,min(1.5,dZ));
        % % k           = k .* sqrt(10.^dZ);

        % % % limit based on inversion results
        % k(k>k_max) = k_max;
        % k(k<k_min) = k_min;

        maxdS    = max(dS);
        mindS    = min(dS);
        meandS   = mean(dS);
        fprintf('MAX dS: %d \n',maxdS) 
        fprintf('MEAN dS: %d \n',meandS) 
        fprintf('MIN dS: %d \n',mindS) 

        vecmaxdS(i)		= maxdS;
        vecmindS(i)		= mindS;
        vecmeandS(i)	= meandS;
        
        if i > 7 && abs((vecmeandS(i) - vecmeandS(i - 1)) / vecmeandS(i - 1)) < maxerror
            break
        elseif i > 15
            break
        end

    end
    toc
    save('steady_state_lia_budd.mat', 'md');
    save('steady_state_lia_convergence.mat', 'vecmeandS', 'vecmaxdS', 'vecmindS');
end
