function [md, vecmaxdS, vecmindS, vecmeandS] = pollard_inversion(md)
    % Inversion of friction coefficient based on Pollard and DeConto (2012) 
    % "A simple inverse method for the distribution of basal sliding
    % coefficients under ice sheets, applied to Antarctica"
    axs = [0.4317, 0.5152, -2.3190, -2.2178] .* 1e6;

    cluster=generic('name', oshostname(), 'np', 30);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

    % parameters
    k = md.friction.C; %Crude initial guess for basal friction
    % k = md.friction.coefficient; %Crude initial guess for basal friction
    k_min = md.inversion.min_parameters(1,1);
    k_max = md.inversion.max_parameters(1,1);

    % area to be updated
    % aoi = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_large.exp', 2));
    aoi = find(ContourToNodes(md.mesh.x, md.mesh.y, '/home/eyhli/IceModeling/work/lia_kq/pollard_update_area.exp', 2));
    % k(aoi) = 350;

    % adjust
    Sinv		= 700;
    timeadjust	= 20;
    finaltime	= 1900;
    maxerror	= 0.01; % relative
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
        md.friction.C = k;
        % md.friction.coefficient = k;

        md.timestepping.start_time				= 1880.;
        md.timestepping.final_time				= 1880 + timeadjust;
        md.timestepping.time_step				= 0.01;
        md.settings.output_frequency			= timeadjust;
        md.transient.requested_outputs		    = {'default', 'IceVolume','MaskIceLevelset', 'MaskOceanLevelset'};
        md.transient.ismovingfront		        = 0;
        md.verbose								= verbose('convergence',true,'solution',true);

        % meltingrate
        md.frontalforcings.meltingrate=20*ones(md.mesh.numberofvertices, 1);

        % run forward in time
        md.cluster= cluster;
        md_tmp=solve(md,'Transient');
        % ok, adjust friction according to ice surface error Smodel-Sobs
        md = transientrestart(md_tmp);
        md = make_floating(md);
  
        % plotmodel(md, 'data', md.mask.ocean_levelset<0, 'figure', 4);
        Smodel	= md.geometry.surface;

        % adjust coefficient
        dS			= Sobs-Smodel;
        plotmodel(md, 'data', dS, 'figure', 20, 'axis#all', axs, 'title', 'dS befre flowline');
        [~, ~, dS, ~] = flowline_traceback(md_tmp, dS, true);
        plotmodel(md, 'data', dS, 'figure', 21, 'axis#all', axs, 'title', 'dS after flowline');
        plotmodel(md, 'data', md.initialization.vel, 'data', md.friction.C, 'figure', 22, 'axis#all', axs, ...
                 'expdisp#2', '/home/eyhli/IceModeling/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_large.exp');
        % plotmodel(md, 'data', md.initialization.vel, 'data', md.friction.coefficient, 'figure', 22, 'axis#all', axs);
        
        dZ			= dS/Sinv;	
        dZ(aoi)			= max(-1.5,min(1.5,dZ(aoi)));
        k(aoi)      = k(aoi).*sqrt(10.^dZ(aoi));
        % dZ			= max(-1.5,min(1.5,dZ));
        % k           = k .* sqrt(10.^dZ);

        % % limit based on inversion results
        k(k>k_max) = k_max;
        k(k<k_min) = k_min;

        maxdS    = max(dS);
        mindS    = min(dS);
        meandS   = mean(dS);
        fprintf('MAX dS: %d \n',maxdS) 
        fprintf('MEAN dS: %d \n',meandS) 
        fprintf('MIN dS: %d \n',mindS) 

        vecmaxdS(i)		= maxdS;
        vecmindS(i)		= mindS;
        vecmeandS(i)	= meandS;
        figure(989); plot(vecmeandS)
        figure(999); plot(vecmeandS, 'k'); hold on; plot(vecmaxdS, 'r.'); plot(vecmindS, 'r.'); hold off;

        if i > 7 && abs((vecmeandS(i) - vecmeandS(i - 1)) / vecmeandS(i - 1)) < maxerror
            break
        elseif i > 35
            break
        end

    end
    toc
    save('pollard_schoof_ssSurface.mat', 'md', '-v7.3');
    save('pollard_schoof_ssSurface_convergence.mat', 'vecmeandS', 'vecmaxdS', 'vecmindS', '-v7.3');
end
