function [md_ss] = steady_state(md, t)
    % Inversion of friction coefficient based on Pollard and DeConto (2012) 
    % "A simple inverse method for the distribution of basal sliding
    % coefficients under ice sheets, applied to Antarctica"
    axs = [0.4317, 0.5152, -2.3190, -2.2178] .* 1e6;

    cluster=generic('name', oshostname(), 'np', 30);
    md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

    % adjust
    timeadjust	= t;
    finaltime	= 1500;
    maxerror	= 0.005; % relative
    nstep		= ceil(finaltime/timeadjust);

    % set timestepping to fixed
    md.timestepping = timestepping();

    % % fix smb forcing to be the average of 1900 for all steps:
    smb_1900_index = md.smb.mass_balance(end, :) < 1901;

    % % repeat for 50 years every month:
    tmp = [repmat(mean(md.smb.mass_balance(1:end-1, smb_1900_index), 2), 1, 12*50); 0:1/12:(50-1/12)];
    md.smb.mass_balance = [tmp, md.smb.mass_balance];

    md.timestepping.start_time				= 0.;
    md.timestepping.final_time				= timeadjust;
    md.timestepping.time_step				= 0.01;
    md.settings.output_frequency			= timeadjust;
    md.transient.requested_outputs		    = {'default'};
    md.transient.ismovingfront		        = 0;
    md.verbose								= verbose('convergence',true,'solution',true);

    % meltingrate
    md.frontalforcings.meltingrate = 20 .* ones(md.mesh.numberofvertices, 1);

    % run forward in time
    md.cluster= cluster;
    md_ss=solve(md,'Transient');
    end