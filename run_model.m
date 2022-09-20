% Main script for running Kangerlussuaq glacier model for period 1900-2020
function [md] = run_model(config_name)
    % if ~exist('md','var')
    %     % third parameter does not exist, so default it to something
    %      md = md;
    % end

    % read config file
    config_path_name = append('Configs/', config_name);
    config = readtable(config_path_name, "TextType", "string");

    %% Set parameters
    try
        steps = str2num(config.ran_steps);
    catch
        steps = config.ran_steps; % in case of single step
    end

    start_time = config.start_time;
    final_time = config.final_time;
    ice_temp = config.ice_temp;
    friction_law = config.friction_law;

    % Inversion parameters
    cf_weights = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];
    cs_min = config.cs_min;
    cs_max = config.cs_max;
    ref_smb_start_time = 1972; % don't change
    ref_smb_final_time = 1989; % don't change

    % Shape file and model name
    glacier = 'kangerlussuaq';
    md.miscellaneous.name = config.model_name;

    % Relevant data paths
    front_shp_file = 'Data/fronts/merged_fronts/merged_fronts.shp';

    if strcmp(config.friction_extrapolation, "texture_synth")
        friction_simulation_file = 'synthetic_friction.mat'; % 'synthetic_friction.mat'; før: texture_synth_friction
    elseif strcmp(config.friction_extrapolation, "random_field")
        disp("RF friction extrapolation method")
    else %TODO: This does not work, and the above is weird too....
        friction_simulation_file = 'semivar_synth_friction.mat'; % 'synth_friction/synthetic_friction.mat';
    end

    if strcmp(config.smb_name, "box")
        smb_file = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    else
        smb_file = 'Data/smb/racmo/';
    end

    % Surface velocity data
    data_vx = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif';
    data_vy = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';

    if sum(steps == 6) == 1
        run_lia_parameterisation = 1;
        disp(run_lia_parameterisation)
    else
        run_lia_parameterisation = 0;
        disp(run_lia_parameterisation)
    end

    % Organizer
    org = organizer('repository', ['./Models'], 'prefix', ['Model_' glacier '_'], 'steps', steps); 
    fprintf("Running model from %d to %d\n", start_time, final_time);
    fprintf("with computation steps %s\n", config.ran_steps);

    clear steps;

    cluster=generic('name', oshostname(), 'np', 39);
    waitonlock = Inf;

    %% 1 Mesh: setup and refine
    if perform(org, 'mesh')
        % domain of interest
        domain = ['Exp/' 'Kangerlussuaq_new' '.exp'];

        % Creates, refines and saves mesh in md
        check_mesh = false;
        md = meshing(domain, data_vx, data_vy, check_mesh);
        savemodel(org, md);
    end

    %% 2 Forcings: Interpolate SMB
    if perform(org, 'smb')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_mesh.mat');
        if strcmp(config.smb_name, "box")
            md = interpolate_box_smb(md, start_time, final_time, smb_file);
        else
            the_files = dir(fullfile(smb_file, '*.nc'));
            %TODO: CANNOT HANDLE ONLY PRE 1958 SELECTION (cat() reconstruct_racmo should be tested for this)
            % reconstruct racmo if year<1958
            if start_time < 1958 || final_time < 1958
                disp("post 1958 - interpolating racmo")
                md = interpolate_racmo_smb(md, 1958, final_time-1, the_files); % -1 to run to end 2021
                disp("pre 1958 - reconstructing racmo")
                md = reconstruct_racmo(md, start_time, final_time-1, ref_smb_start_time, ref_smb_final_time);
            else
                disp("post 1958 - interpolating racmo")
                md = interpolate_racmo_smb(md, start_time, final_time-1, the_files);
            end
        end 
        savemodel(org, md);
    end

    %% 3 Parameterisation: Default setup with .par file
    if perform(org, 'param')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_smb.mat');

        md = setflowequation(md,'SSA','all');
        md = setmask(md,'','');

        md = parameterize(md, 'ParameterFiles/inversion_present_day.par');

        % Outside to avoid having to write custom parametrize function. For now grid search over temp is also fine to start with.
        md.materials.rheology_B = cuffey(273.15 + ice_temp) * ones(md.mesh.numberofvertices, 1);

        savemodel(org, md);
    end

    %% 4 Friction law setup: Budd
    if perform(org, 'budd')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_param.mat');
        md = solve_stressbalance(md, cf_weights, cs_min, cs_max);
        savemodel(org, md);
    end

    %% 5 Friction law setup: Schoof
    if perform(org, 'schoof')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_budd.mat');
        % md = solve_stressbalance(md, cf_weights, cs_min, cs_max);
        [md] = budd2schoof(md);
        savemodel(org, md);
    end

    %% 6 Redefine levelset and thickness
    if perform(org, 'lia_param')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_schoof.mat');
        md = parameterize(md, 'ParameterFiles/transient_lia.par');

        % synthesize friction coefficient in under past ice
        % md = fill_in_texture(md, friction_simulation_file);  
        if strcmp(config.friction_extrapolation, "random_field")
            disp("Extrapolating friction coefficient using Random field method")
            [front_area_fric, front_area_pos] = extrapolate_friction_rf(md); 
        elseif strcmp(config.friction_extrapolation, "linear")
            disp("Extrapolating friction coefficient linearly")
            [front_area_fric, front_area_pos] = extrapolate_friction_linear(md); 
        elseif strcmp(config.friction_extrapolation, "constant")
            disp("Extrapolating friction coefficient using constant value")
            [front_area_fric, front_area_pos] = extrapolate_friction_constant(md); 
        else
            warning("Invalid extrapolation method from config file. Choose random_field, linear or constant")
        end
        
        md.friction.C(front_area_pos) = front_area_fric;
        savemodel(org, md);
    end

    %% 7 Initialise: Setup and load calving fronts
    if perform(org, 'fronts')
        if run_lia_parameterisation == 1
            disp("Using LIA initial conditoins")
            md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_lia_param.mat');
        else
            disp("Not using LIA initial conditions")
            md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_friction.mat');
        end

        md = fronts_init(md, ice_temp, start_time, final_time); % initialises fronts
        md = fronts_transient(md, front_shp_file); % loads front observations
        savemodel(org, md);
    end

    %% 8 Transient: setup & run
    if perform(org, 'transient')
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_fronts.mat');

        % meltingrate
        timestamps = [md.timestepping.start_time, md.timestepping.final_time];
        md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices+1, numel(timestamps));
        md.frontalforcings.meltingrate(end, :) = timestamps;

        md.cluster = cluster;
        md.verbose.solution = 1;

        % fast solver
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
        
        % get output
        md.transient.requested_outputs={'default', 'IceVolume', 'IceVolumeAboveFloatation'}; %,'IceVolume','MaskIceLevelset', 'MaskOceanLevelset'};

        md.settings.waitonlock = waitonlock; % do not wait for complete
        disp('SOLVE')
        md=solve(md,'Transient','runtimename',false);
        disp('SAVE')
        savemodel(org, md);

        %TODO: RUN DIAGNOSTICS AND SAVE IN RESULTS/DATE FOLDER!!!!!
    end
end