function [md] = fronts_init(md, output_frequency, start_time, final_time)
    % initialisation
    % md.initialization.pressure = zeros(md.mesh.numberofvertices, 1); 
    % md.initialization.temperature = (273.15 + ice_temp) * ones(md.mesh.numberofvertices, 1); 

    % set timestepping
    md.timestepping=timesteppingadaptive();  % will adapt time step size in every step.
    md.timestepping.start_time = start_time;
    md.timestepping.final_time = final_time;
    md.timestepping.time_step_max = 0.1; % max step size wrt CFL condition
    md.timestepping.time_step_min = 0.0005; % min step size wrt CFL condition
    md.settings.output_frequency = output_frequency; % every 5th step is saved in md.results
    % md.timestepping.time_step  = 0.005; % static step
    % md.settings.output_frequency = 1; % static step

    md.transient.isslc = 0; % indicates whether a sea-level change solution is used in the transient
    md.transient.isthermal = 0; % indicates whether a thermal solution is used in the transient
    md.transient.isstressbalance=1; % indicates whether a stressbalance solution is used in the transient
    md.transient.ismasstransport=1; % indicates whether a masstransport solution is used in the transient
    md.transient.isgroundingline=1; % indicates whether a groundingline migration is used in the transient
    md.groundingline.migration = 'SubelementMigration'; 
    md = sethydrostaticmask(md);
end 