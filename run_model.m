% Main script for running Kangerlussuaq glacier model for period 1900-2020
function [md] = run_model(config_name, plotting_flag)
    % if ~exist('md','var')
    %     % third parameter does not exist, so default it to something
    %      md = md;
    % end
    if nargin < 2
        plotting_flag = false;
    end
    
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

    cluster=generic('name', oshostname(), 'np', 66);
    waitonlock = Inf;

    %% 1 Mesh: setup and refine
    if perform(org, 'mesh')
        % domain of interest
        % domain = ['Exp/' 'Kangerlussuaq_new' '.exp'];
        domain = ['Exp/' 'Kangerlussuaq_full_basin' '.exp'];

        % Creates, refines and saves mesh in md
        check_mesh = false;
        md = meshing(domain, data_vx, data_vy, check_mesh);
        savemodel(org, md);
        if plotting_flag
            plotmodel(md, 'data', 'mesh'); exportgraphics(gcf, "mesh.png")
        end
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

        if plotting_flag
            figure(1);
            plotmodel(md, 'data', md.friction.coefficient, 'title', 'Budd Friction Law, Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', []); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_friction.png")

            figure(2);
            plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'title', 'Budd Friction Law, Velocity', ...
            'colorbar', 'off', 'xtick', [], 'ytick', []); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_sb_vel.png")
        end
        
    end

    %% 5 Friction law setup: Schoof
    if perform(org, 'schoof')
        friction_law = 'schoof';
        md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_budd.mat');
        % md = loadmodel('/data/eigil/work/lia_kq/Models/baseline/Model_kangerlussuaq_friction.mat');
        coefs = [4000, 2.2, 2.51e-9, 0.667]; % found through grid search %TODO: L-curve
        [md] = budd2schoof(md, coefs);
        savemodel(org, md);
        if plotting_flag
            figure(3);
            plotmodel(md, 'data', md.friction.C, 'title', 'Schoof Friction Law, Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', []); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "schoof_friction.png")

            figure(4);
            plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'title', 'Schoof Friction Law, Velocity', ...
            'colorbar', 'off', 'xtick', [], 'ytick', []); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "schoof_sb_vel.png")
        end
    end

    %% 6 Parameterize LIA, extrapolate friction coefficient to LIA front
    if perform(org, 'lia_param')
        warning('!!!!You need to implement temperature extrapolation as well!!!!!')

        
        if strcmp(config.friction_law, 'schoof')
            md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_schoof.mat');
        elseif strcmp(config.friction_law, 'budd')
            md = loadmodel('/data/eigil/work/lia_kq/Models/Model_kangerlussuaq_budd.mat');
        else
            warning("Friction law not implemented")
        end
        md = parameterize(md, 'ParameterFiles/transient_lia.par');
        validate_flag = false;

        % synthesize friction coefficient in under past ice
        % md = fill_in_texture(md, friction_simulation_file);  
        if strcmp(config.friction_extrapolation, "random_field")
            disp("Extrapolating friction coefficient using Random field method")
            [extrapolated_friction, extrapolated_pos, mae_rf] = friction_random_field_model(md, cs_min, config.friction_law, validate_flag); 
        elseif strcmp(config.friction_extrapolation, "bed_correlation")
            M = 1; % polynomial order

            disp("Extrapolating friction coefficient correlated linearly with bed topography")
            [extrapolated_friction, extrapolated_pos, mae_poly] = friction_polynomial_model(md, cs_min, M, config.friction_law, validate_flag); 
 
        elseif strcmp(config.friction_extrapolation, "constant")
            disp("Extrapolating friction coefficient using constant value")
            [extrapolated_friction, extrapolated_pos, mae_const] = friction_constant_model(md, cs_min, config.friction_law, validate_flag);
        else
            warning("Invalid extrapolation method from config file. Choose random_field, linear or constant")
        end
        
        if strcmp(config.friction_law, 'schoof')
            md.friction.C(extrapolated_pos) = extrapolated_friction;
            if plotting_flag
                figure(5);
                plotmodel(md, 'data', md.friction.C, 'title', 'Budd Friction Law', ...
                'colorbar', 'off', 'xtick', [], 'ytick', []); 
                set(gca,'fontsize',12);
                set(colorbar,'visible','off')
                h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
                colormap('turbo'); 
                exportgraphics(gcf, "budd_friction_extrapolated.png")
            end
            
        elseif strcmp(config.friction_law, 'budd')
            md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
            if plotting_flag
                figure(6);
                plotmodel(md, 'data', md.friction.coefficient, 'title', 'Budd Friction Law', ...
                'colorbar', 'off', 'xtick', [], 'ytick', []); 
                set(gca,'fontsize',12);
                set(colorbar,'visible','off')
                h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
                colormap('turbo'); 
                exportgraphics(gcf, "budd_friction_extrapolated.png")
            end
        else
            warning('Friction law not recignised, choose schoof or budd')
        end

        figure(7);
        plotmodel(md, 'data', md.geometry.thickness, 'title', 'LIA thickness', ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        colormap('turbo'); 
        exportgraphics(gcf, "lia_thickness.png")

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