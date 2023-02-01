function [md, vecmaxdS, vecmindS, vecmeandS] = pollard_inversion(md)
    % Inversion of friction coefficient based on Pollard and DeConto (2012) 
    % "A simple inverse method for the distribution of basal sliding
    % coefficients under ice sheets, applied to Antarctica"
    cluster=generic('name', oshostname(), 'np', 30);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

    % parameters
    k = md.friction.coefficient; %Crude initial guess for basal friction

    % area to be updated
    aoi = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));

    % adjust
    Sinv		= 600;
    timeadjust	= 25;
    finaltime	= 4000;
    maxerror	= 0.015; % relative
    nstep		= ceil(finaltime/timeadjust);

    % get Sobs (surface) and initial Smodel (surface) on 2D mesh
    Sobs			= md.geometry.surface;

    vecmaxdS		= [];
    vecmindS		= [];
    vecmeandS	= [];
    tic
    for i=1:nstep
        fprintf('CASE: %d.   STEP: %d. \n',1,i) 

        % set friction coefficient and rheology
        md.friction.coefficient = k;

        md.timestepping.start_time				= 0.;
        md.timestepping.final_time				= timeadjust;
        % md.timestepping.time_step				= 0.5;
        md.settings.output_frequency			= timeadjust;
        md.transient.requested_outputs		= {'IceVolume','TotalSmb','SmbMassBalance'};
        md.verbose									= verbose('convergence',true,'solution',true);

        % meltingrate
        md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices, 1);

        % run forward in time
        md.cluster= cluster;
        md=solve(md,'Transient');

        % ok, adjust friction according to ice surface error Smodel-Sobs
        md = transientrestart(md);
        Smodel	= md.geometry.surface;

        % adjust coefficient
        dS			= Sobs-Smodel;
        dZ			= dS/Sinv;	
        dZ(aoi)			= max(-1.5,min(1.5,dZ(aoi)));
        k(aoi)      = k(aoi).*sqrt(10.^dZ(aoi));

        maxdS    = max(dS);
        mindS    = min(dS);
        meandS   = mean(dS);
        fprintf('MAX dS: %d \n',maxdS) 
        fprintf('MEAN dS: %d \n',meandS) 
        fprintf('MIN dS: %d \n',mindS) 

        vecmaxdS(i)		= maxdS;
        vecmindS(i)		= mindS;
        vecmeandS(i)	= meandS;

        if i > 10 && abs((vecmeandS(i) - vecmeandS(i - 1)) / vecmeandS(i - 1)) < maxerror
            break
        end
    end
    toc
end
